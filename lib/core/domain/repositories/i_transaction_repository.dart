import '../entities/transaction.dart';

abstract class ITransactionRepository {
  Stream<List<TransactionEntity>> watchAllTransactions();
  Stream<List<TransactionEntity>> watchTransactionsByAccount(String accountId);
  Future<List<TransactionEntity>> getTransactions({
    int limit = 100,
    int offset = 0,
    String? accountId,
    String? categoryId,
    String? merchantId,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    TransactionType? type,
    TransactionStatus? status,
    String? searchQuery,
  });
  Future<TransactionEntity?> getTransactionById(String id);
  Future<void> createTransaction(TransactionEntity transaction);
  Future<void> updateTransaction(TransactionEntity transaction);
  Future<void> deleteTransaction(String id);
  Future<void> bulkDeleteTransactions(List<String> ids);
  Future<void> bulkUpdateCategory(
      {required List<String> ids, required String categoryId});
  Future<void> createTransfer({
    required String sourceAccountId,
    required String destinationAccountId,
    required double amount,
    required DateTime date,
    required String description,
    String? notes,
  });
}
