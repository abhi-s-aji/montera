import 'package:monetra/core/domain/entities/recurring_schedule.dart';
import 'package:monetra/core/domain/entities/transaction.dart';

class RecurrenceCalculator {
  static DateTime calculateNextExecution({
    required DateTime fromDate,
    required RecurrenceFrequency frequency,
  }) {
    switch (frequency) {
      case RecurrenceFrequency.daily:
        return fromDate.add(const Duration(days: 1));
      case RecurrenceFrequency.weekly:
        return fromDate.add(const Duration(days: 7));
      case RecurrenceFrequency.biweekly:
        return fromDate.add(const Duration(days: 14));
      case RecurrenceFrequency.monthly:
        return DateTime(fromDate.year, fromDate.month + 1, fromDate.day);
      case RecurrenceFrequency.quarterly:
        return DateTime(fromDate.year, fromDate.month + 3, fromDate.day);
      case RecurrenceFrequency.yearly:
        return DateTime(fromDate.year + 1, fromDate.month, fromDate.day);
      case RecurrenceFrequency.custom:
        return fromDate.add(const Duration(days: 30));
    }
  }
}

class RecurringExecutionEngine {
  static List<TransactionEntity> generateDueTransactions({
    required List<RecurringSchedule> schedules,
    required DateTime currentDate,
  }) {
    final List<TransactionEntity> generated = [];

    for (final schedule in schedules) {
      if (schedule.status != RecurringScheduleStatus.active) continue;

      if (schedule.nextExecutionDate.isBefore(currentDate) ||
          schedule.nextExecutionDate.isAtSameMomentAs(currentDate)) {
        generated.add(
          TransactionEntity(
            id: 'auto-tx-${DateTime.now().microsecondsSinceEpoch}-${schedule.id.hashCode}',
            accountId: schedule.accountId,
            categoryId: schedule.categoryId,
            amount: schedule.amount,
            type: schedule.type,
            date: schedule.nextExecutionDate,
            description: schedule.title,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      }
    }
    return generated;
  }
}
