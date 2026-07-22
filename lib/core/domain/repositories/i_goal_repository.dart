import '../entities/goal.dart';

abstract class IGoalRepository {
  Stream<List<Goal>> watchAllGoals({bool includeArchived = false});
  Future<List<Goal>> getAllGoals({bool includeArchived = false});
  Future<Goal?> getGoalById(String id);
  Future<void> createGoal(Goal goal);
  Future<void> updateGoal(Goal goal);
  Future<void> archiveGoal(String id, bool archiveStatus);
  Future<void> deleteGoal(String id);
  Future<void> contributeToGoal(
      {required String goalId, required double amount});
  Future<void> withdrawFromGoal(
      {required String goalId, required double amount});
  Future<Goal> duplicateGoal(String id);
}
