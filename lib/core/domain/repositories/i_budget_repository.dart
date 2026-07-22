import '../entities/budget.dart';

abstract class IBudgetRepository {
  Stream<List<Budget>> watchAllBudgets({bool includeArchived = false});
  Future<List<Budget>> getAllBudgets({bool includeArchived = false});
  Future<Budget?> getBudgetById(String id);
  Future<void> createBudget(Budget budget);
  Future<void> updateBudget(Budget budget);
  Future<void> archiveBudget(String id, bool archiveStatus);
  Future<void> deleteBudget(String id);
  Future<Budget> duplicateBudget(String id);
}
