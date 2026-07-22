import 'dart:async';
import 'package:uuid/uuid.dart';

import '../../domain/entities/goal.dart';
import '../../domain/repositories/i_goal_repository.dart';

class GoalRepositoryImpl implements IGoalRepository {
  final List<Goal> _goals = [];
  final StreamController<List<Goal>> _streamController =
      StreamController<List<Goal>>.broadcast();

  GoalRepositoryImpl([List<Goal>? initialGoals]) {
    if (initialGoals != null) {
      _goals.addAll(initialGoals);
    } else {
      _seedDefaultGoals();
    }
    _emit();
  }

  void _seedDefaultGoals() {
    final now = DateTime.now();
    _goals.addAll([
      Goal(
        id: 'goal-emergency-1',
        title: '6-Month Emergency Fund',
        description:
            'Safety net covering 6 months of essential living expenses',
        type: GoalType.emergencyFund,
        targetAmount: 15000.0,
        currentAmount: 8500.0,
        targetDate: now.add(const Duration(days: 180)),
        priority: 1,
        colorHex: '#10B981',
        icon: 'security',
        createdAt: now,
        updatedAt: now,
      ),
      Goal(
        id: 'goal-vacation-1',
        title: 'Japan Summer Trip 2027',
        description: 'Flights, accommodations, and bullet train passes',
        type: GoalType.vacation,
        targetAmount: 4500.0,
        currentAmount: 1800.0,
        targetDate: now.add(const Duration(days: 300)),
        priority: 2,
        colorHex: '#06B6D4',
        icon: 'flight',
        createdAt: now,
        updatedAt: now,
      ),
      Goal(
        id: 'goal-laptop-1',
        title: 'M4 MacBook Pro Upgrade',
        description: 'Workstation upgrade for mobile software development',
        type: GoalType.savings,
        targetAmount: 2800.0,
        currentAmount: 2100.0,
        targetDate: now.add(const Duration(days: 60)),
        priority: 2,
        colorHex: '#6366F1',
        icon: 'laptop_mac',
        createdAt: now,
        updatedAt: now,
      ),
    ]);
  }

  void _emit() {
    final active = _goals.where((g) => !g.isDeleted).toList();
    active.sort((a, b) => a.priority.compareTo(b.priority));
    _streamController.add(active);
  }

  @override
  Stream<List<Goal>> watchAllGoals({bool includeArchived = false}) {
    return _streamController.stream.map(
      (list) => list.where((g) => includeArchived || !g.isArchived).toList(),
    );
  }

  @override
  Future<List<Goal>> getAllGoals({bool includeArchived = false}) async {
    final list = _goals
        .where((g) => !g.isDeleted && (includeArchived || !g.isArchived))
        .toList();
    list.sort((a, b) => a.priority.compareTo(b.priority));
    return list;
  }

  @override
  Future<Goal?> getGoalById(String id) async {
    try {
      return _goals.firstWhere((g) => g.id == id && !g.isDeleted);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> createGoal(Goal goal) async {
    _goals.add(goal);
    _emit();
  }

  @override
  Future<void> updateGoal(Goal goal) async {
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _goals[index] = goal.copyWith(
        updatedAt: DateTime.now(),
        version: goal.version + 1,
      );
      _emit();
    }
  }

  @override
  Future<void> archiveGoal(String id, bool archiveStatus) async {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index != -1) {
      _goals[index] = _goals[index].copyWith(
        isArchived: archiveStatus,
        updatedAt: DateTime.now(),
      );
      _emit();
    }
  }

  @override
  Future<void> deleteGoal(String id) async {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index != -1) {
      _goals[index] = _goals[index].copyWith(
        isDeleted: true,
        updatedAt: DateTime.now(),
      );
      _emit();
    }
  }

  @override
  Future<void> contributeToGoal(
      {required String goalId, required double amount}) async {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      final current = _goals[index];
      final newAmt = current.currentAmount + amount;
      final newStatus = newAmt >= current.targetAmount
          ? GoalStatus.completed
          : current.status;

      _goals[index] = current.copyWith(
        currentAmount: newAmt,
        status: newStatus,
        updatedAt: DateTime.now(),
      );
      _emit();
    }
  }

  @override
  Future<void> withdrawFromGoal(
      {required String goalId, required double amount}) async {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      final current = _goals[index];
      final newAmt =
          (current.currentAmount - amount).clamp(0.0, double.infinity);

      _goals[index] = current.copyWith(
        currentAmount: newAmt,
        updatedAt: DateTime.now(),
      );
      _emit();
    }
  }

  @override
  Future<Goal> duplicateGoal(String id) async {
    final original = await getGoalById(id);
    if (original == null) throw Exception('Goal not found');

    final now = DateTime.now();
    final duplicate = original.copyWith(
      id: 'goal-${const Uuid().v4()}',
      title: '${original.title} (Copy)',
      createdAt: now,
      updatedAt: now,
      version: 1,
    );
    await createGoal(duplicate);
    return duplicate;
  }

  void dispose() {
    _streamController.close();
  }
}
