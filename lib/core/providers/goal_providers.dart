import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/goal.dart';
import 'repository_providers.dart';

final goalSearchQueryProvider = StateProvider<String>((ref) => '');
final goalTypeFilterProvider = StateProvider<GoalType?>((ref) => null);
final goalShowArchivedProvider = StateProvider<bool>((ref) => false);

// Watch Goals Stream Provider
final goalsStreamProvider = StreamProvider<List<Goal>>((ref) {
  final repo = ref.watch(goalRepositoryProvider);
  final showArchived = ref.watch(goalShowArchivedProvider);
  return repo.watchAllGoals(includeArchived: showArchived);
});

// Filtered & Priority Sorted Goals Provider
final filteredGoalsProvider = Provider<List<Goal>>((ref) {
  final goalsAsync = ref.watch(goalsStreamProvider);
  final query = ref.watch(goalSearchQueryProvider).trim().toLowerCase();
  final typeFilter = ref.watch(goalTypeFilterProvider);

  return goalsAsync.when(
    data: (goals) {
      return goals.where((g) {
        final matchesQuery = query.isEmpty ||
            g.title.toLowerCase().contains(query) ||
            (g.description?.toLowerCase().contains(query) ?? false);
        final matchesType = typeFilter == null || g.type == typeFilter;
        return matchesQuery && matchesType;
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Goal Progress & Projection Calculation Engine Provider
final goalProgressListProvider = Provider<List<GoalProgressCalculation>>((ref) {
  final goals = ref.watch(filteredGoalsProvider);
  final now = DateTime.now();

  return goals.map((g) {
    final remaining =
        (g.targetAmount - g.currentAmount).clamp(0.0, double.infinity);
    final progress = (g.currentAmount / g.targetAmount).clamp(0.0, 1.0);
    final daysLeft = g.targetDate != null
        ? g.targetDate!.difference(now).inDays.clamp(1, 3650)
        : 365;

    final daily = remaining / daysLeft;
    final monthly = remaining / (daysLeft / 30.0);

    return GoalProgressCalculation(
      goal: g,
      remainingAmount: remaining,
      progressPercentage: progress,
      remainingDays: daysLeft,
      requiredDailyContribution: daily,
      requiredMonthlyContribution: monthly,
    );
  }).toList();
});
