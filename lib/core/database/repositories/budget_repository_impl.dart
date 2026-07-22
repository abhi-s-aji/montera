import 'dart:async';
import 'package:uuid/uuid.dart';

import '../../domain/entities/budget.dart';
import '../../domain/repositories/i_budget_repository.dart';

class BudgetRepositoryImpl implements IBudgetRepository {
  final List<Budget> _budgets = [];
  final StreamController<List<Budget>> _streamController =
      StreamController<List<Budget>>.broadcast();

  BudgetRepositoryImpl([List<Budget>? initialBudgets]) {
    if (initialBudgets != null) {
      _budgets.addAll(initialBudgets);
    } else {
      _seedDefaultBudgets();
    }
    _emit();
  }

  void _seedDefaultBudgets() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    _budgets.addAll([
      Budget(
        id: 'budget-housing-1',
        name: 'Housing & Rent Cap',
        description: 'Monthly ceiling for rent and utilities',
        type: BudgetType.category,
        categoryId: 'cat-housing',
        amount: 1800.0,
        period: BudgetPeriod.monthly,
        startDate: startOfMonth,
        endDate: endOfMonth,
        createdAt: now,
        updatedAt: now,
      ),
      Budget(
        id: 'budget-groceries-1',
        name: 'Groceries Spending Limit',
        description: 'Food and supermarket expenses cap',
        type: BudgetType.category,
        categoryId: 'cat-groceries',
        amount: 600.0,
        period: BudgetPeriod.monthly,
        startDate: startOfMonth,
        endDate: endOfMonth,
        createdAt: now,
        updatedAt: now,
      ),
      Budget(
        id: 'budget-dining-1',
        name: 'Dining & Coffee Allowance',
        description: 'Takeout and coffee shop limit',
        type: BudgetType.category,
        categoryId: 'cat-dining',
        amount: 250.0,
        period: BudgetPeriod.monthly,
        startDate: startOfMonth,
        endDate: endOfMonth,
        createdAt: now,
        updatedAt: now,
      ),
    ]);
  }

  void _emit() {
    final active = _budgets.where((b) => !b.isDeleted).toList();
    _streamController.add(active);
  }

  @override
  Stream<List<Budget>> watchAllBudgets({bool includeArchived = false}) {
    return _streamController.stream.map(
      (list) => list.where((b) => includeArchived || !b.isArchived).toList(),
    );
  }

  @override
  Future<List<Budget>> getAllBudgets({bool includeArchived = false}) async {
    return _budgets
        .where((b) => !b.isDeleted && (includeArchived || !b.isArchived))
        .toList();
  }

  @override
  Future<Budget?> getBudgetById(String id) async {
    try {
      return _budgets.firstWhere((b) => b.id == id && !b.isDeleted);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> createBudget(Budget budget) async {
    _budgets.add(budget);
    _emit();
  }

  @override
  Future<void> updateBudget(Budget budget) async {
    final index = _budgets.indexWhere((b) => b.id == budget.id);
    if (index != -1) {
      _budgets[index] = budget.copyWith(
        updatedAt: DateTime.now(),
        version: budget.version + 1,
      );
      _emit();
    }
  }

  @override
  Future<void> archiveBudget(String id, bool archiveStatus) async {
    final index = _budgets.indexWhere((b) => b.id == id);
    if (index != -1) {
      _budgets[index] = _budgets[index].copyWith(
        isArchived: archiveStatus,
        updatedAt: DateTime.now(),
      );
      _emit();
    }
  }

  @override
  Future<void> deleteBudget(String id) async {
    final index = _budgets.indexWhere((b) => b.id == id);
    if (index != -1) {
      _budgets[index] = _budgets[index].copyWith(
        isDeleted: true,
        updatedAt: DateTime.now(),
      );
      _emit();
    }
  }

  @override
  Future<Budget> duplicateBudget(String id) async {
    final original = await getBudgetById(id);
    if (original == null) throw Exception('Budget not found');

    final now = DateTime.now();
    final duplicate = original.copyWith(
      id: 'budget-${const Uuid().v4()}',
      name: '${original.name} (Copy)',
      createdAt: now,
      updatedAt: now,
      version: 1,
    );
    await createBudget(duplicate);
    return duplicate;
  }
}
