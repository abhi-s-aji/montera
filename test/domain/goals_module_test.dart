import 'package:flutter_test/flutter_test.dart';
import 'package:monetra/core/database/repositories/goal_repository_impl.dart';
import 'package:monetra/core/domain/entities/goal.dart';

void main() {
  late GoalRepositoryImpl repository;

  setUp(() {
    repository = GoalRepositoryImpl([]);
  });

  group('Goals & Savings Module Unit Tests', () {
    test('createGoal persists savings target to repository', () async {
      final now = DateTime.now();
      final goal = Goal(
        id: 'goal-test-1',
        title: 'New Laptop',
        type: GoalType.savings,
        targetAmount: 2000.0,
        currentAmount: 500.0,
        createdAt: now,
        updatedAt: now,
      );

      await repository.createGoal(goal);
      final list = await repository.getAllGoals();

      expect(list.length, equals(1));
      expect(list.first.title, equals('New Laptop'));
      expect(list.first.targetAmount, equals(2000.0));
    });

    test(
        'contributeToGoal updates current amount and marks completed when target is met',
        () async {
      final now = DateTime.now();
      final goal = Goal(
        id: 'goal-c-1',
        title: 'Car Down Payment',
        type: GoalType.vehicle,
        targetAmount: 1000.0,
        currentAmount: 800.0,
        createdAt: now,
        updatedAt: now,
      );

      await repository.createGoal(goal);
      await repository.contributeToGoal(goalId: 'goal-c-1', amount: 250.0);

      final updated = await repository.getGoalById('goal-c-1');
      expect(updated?.currentAmount, equals(1050.0));
      expect(updated?.status, equals(GoalStatus.completed));
    });

    test('withdrawFromGoal reduces current saved balance', () async {
      final now = DateTime.now();
      final goal = Goal(
        id: 'goal-w-1',
        title: 'Vacation Reserve',
        type: GoalType.vacation,
        targetAmount: 3000.0,
        currentAmount: 1500.0,
        createdAt: now,
        updatedAt: now,
      );

      await repository.createGoal(goal);
      await repository.withdrawFromGoal(goalId: 'goal-w-1', amount: 500.0);

      final updated = await repository.getGoalById('goal-w-1');
      expect(updated?.currentAmount, equals(1000.0));
    });

    test('duplicateGoal creates twin goal record with copy title suffix',
        () async {
      final now = DateTime.now();
      final goal = Goal(
        id: 'goal-d-1',
        title: 'Retirement Fund',
        type: GoalType.retirement,
        targetAmount: 500000.0,
        currentAmount: 100000.0,
        createdAt: now,
        updatedAt: now,
      );

      await repository.createGoal(goal);
      final duplicate = await repository.duplicateGoal('goal-d-1');

      expect(duplicate.title, equals('Retirement Fund (Copy)'));
      expect(duplicate.targetAmount, equals(500000.0));
      expect(duplicate.id, isNot(equals('goal-d-1')));
    });
  });
}
