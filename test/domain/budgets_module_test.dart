import 'package:flutter_test/flutter_test.dart';
import 'package:monetra/core/database/repositories/budget_repository_impl.dart';
import 'package:monetra/core/domain/entities/budget.dart';

void main() {
  late BudgetRepositoryImpl repository;

  setUp(() {
    repository = BudgetRepositoryImpl([]);
  });

  group('Budgets Module Unit & Progress Tests', () {
    test('createBudget persists budget limit to repository', () async {
      final now = DateTime.now();
      final b = Budget(
        id: 'budget-test-1',
        name: 'Dining Budget',
        type: BudgetType.category,
        categoryId: 'cat-dining',
        amount: 300.0,
        period: BudgetPeriod.monthly,
        startDate: DateTime(now.year, now.month, 1),
        endDate: DateTime(now.year, now.month + 1, 0),
        createdAt: now,
        updatedAt: now,
      );

      await repository.createBudget(b);
      final list = await repository.getAllBudgets();

      expect(list.length, equals(1));
      expect(list.first.name, equals('Dining Budget'));
      expect(list.first.amount, equals(300.0));
    });

    test('duplicateBudget creates cloned budget record with copy suffix',
        () async {
      final now = DateTime.now();
      final b = Budget(
        id: 'budget-orig-1',
        name: 'Tech Cap',
        type: BudgetType.category,
        categoryId: 'cat-tech',
        amount: 500.0,
        period: BudgetPeriod.monthly,
        startDate: DateTime(now.year, now.month, 1),
        endDate: DateTime(now.year, now.month + 1, 0),
        createdAt: now,
        updatedAt: now,
      );

      await repository.createBudget(b);
      final duplicate = await repository.duplicateBudget('budget-orig-1');

      expect(duplicate.name, equals('Tech Cap (Copy)'));
      expect(duplicate.amount, equals(500.0));
      expect(duplicate.id, isNot(equals('budget-orig-1')));
    });

    test('archiveBudget toggles archive status flag', () async {
      final now = DateTime.now();
      final b = Budget(
        id: 'b-arch-1',
        name: 'Archived Budget',
        type: BudgetType.category,
        amount: 100.0,
        period: BudgetPeriod.monthly,
        startDate: now,
        endDate: now,
        createdAt: now,
        updatedAt: now,
      );

      await repository.createBudget(b);
      await repository.archiveBudget('b-arch-1', true);

      final active = await repository.getAllBudgets(includeArchived: false);
      expect(active.isEmpty, isTrue);
    });
  });
}
