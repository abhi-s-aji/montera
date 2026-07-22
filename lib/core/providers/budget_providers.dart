import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/budget.dart';
import 'repository_providers.dart';
import 'transaction_providers.dart';

final budgetSearchQueryProvider = StateProvider<String>((ref) => '');
final budgetShowArchivedProvider = StateProvider<bool>((ref) => false);

// Watch Budgets Stream Provider
final budgetsStreamProvider = StreamProvider<List<Budget>>((ref) {
  final repo = ref.watch(budgetRepositoryProvider);
  final showArchived = ref.watch(budgetShowArchivedProvider);
  return repo.watchAllBudgets(includeArchived: showArchived);
});

// Filtered Budgets Provider
final filteredBudgetsProvider = Provider<List<Budget>>((ref) {
  final budgetsAsync = ref.watch(budgetsStreamProvider);
  final query = ref.watch(budgetSearchQueryProvider).trim().toLowerCase();

  return budgetsAsync.when(
    data: (budgets) {
      return budgets.where((b) {
        return query.isEmpty ||
            b.name.toLowerCase().contains(query) ||
            (b.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Real-Time Budget Progress & Velocity Engine Provider
final budgetProgressListProvider =
    Provider<List<BudgetProgressCalculation>>((ref) {
  final budgets = ref.watch(filteredBudgetsProvider);
  final transactionsAsync = ref.watch(transactionsStreamProvider);
  final transactions = transactionsAsync.value ?? [];

  final now = DateTime.now();

  return budgets.map((budget) {
    double spent = 0;
    for (final tx in transactions) {
      if (tx.amount < 0 && tx.categoryId == budget.categoryId) {
        if (tx.date.isAfter(budget.startDate) &&
            tx.date.isBefore(budget.endDate.add(const Duration(days: 1)))) {
          spent += tx.amount.abs();
        }
      }
    }

    final remaining = budget.amount - spent;
    final progress = (spent / budget.amount).clamp(0.0, 1.0);
    final isOver = spent > budget.amount;
    final daysLeft = budget.endDate.difference(now).inDays.clamp(1, 365);
    final dailyAllowance = isOver ? 0.0 : remaining / daysLeft;

    return BudgetProgressCalculation(
      budget: budget,
      spentAmount: spent,
      remainingAmount: remaining,
      progress: progress,
      isOverBudget: isOver,
      dailyAllowance: dailyAllowance,
      remainingDays: daysLeft,
    );
  }).toList();
});
