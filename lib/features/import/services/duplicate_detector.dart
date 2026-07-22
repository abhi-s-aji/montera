import 'package:monetra/core/domain/entities/transaction.dart';

class DuplicateDetector {
  static bool isDuplicate({
    required TransactionEntity candidate,
    required List<TransactionEntity> existingTransactions,
  }) {
    for (final existing in existingTransactions) {
      if (candidate.id == existing.id) return true;

      // Composite match signature: Same account, same amount, same date, same description
      if (candidate.accountId == existing.accountId &&
          (candidate.amount - existing.amount).abs() < 0.001 &&
          candidate.date.year == existing.date.year &&
          candidate.date.month == existing.date.month &&
          candidate.date.day == existing.date.day &&
          candidate.description.trim().toLowerCase() ==
              existing.description.trim().toLowerCase()) {
        return true;
      }
    }
    return false;
  }
}
