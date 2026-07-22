import 'package:flutter_test/flutter_test.dart';

import 'package:monetra/core/domain/entities/recurring_schedule.dart';
import 'package:monetra/core/domain/entities/transaction.dart';
import 'package:monetra/features/automation/services/recurring_engine_services.dart';

void main() {
  group('Monetra Recurring Transactions & Automation Engine Unit Tests', () {
    test('RecurrenceCalculator computes next execution dates deterministically',
        () {
      final startDate = DateTime(2026, 7, 1);

      final daily = RecurrenceCalculator.calculateNextExecution(
          fromDate: startDate, frequency: RecurrenceFrequency.daily);
      expect(daily, equals(DateTime(2026, 7, 2)));

      final weekly = RecurrenceCalculator.calculateNextExecution(
          fromDate: startDate, frequency: RecurrenceFrequency.weekly);
      expect(weekly, equals(DateTime(2026, 7, 8)));

      final biweekly = RecurrenceCalculator.calculateNextExecution(
          fromDate: startDate, frequency: RecurrenceFrequency.biweekly);
      expect(biweekly, equals(DateTime(2026, 7, 15)));

      final monthly = RecurrenceCalculator.calculateNextExecution(
          fromDate: startDate, frequency: RecurrenceFrequency.monthly);
      expect(monthly, equals(DateTime(2026, 8, 1)));

      final yearly = RecurrenceCalculator.calculateNextExecution(
          fromDate: startDate, frequency: RecurrenceFrequency.yearly);
      expect(yearly, equals(DateTime(2027, 7, 1)));
    });

    test(
        'RecurringExecutionEngine generates due transaction records accurately',
        () {
      final dueSchedule = RecurringSchedule(
        id: 'sch-due',
        title: 'Internet Service Bill',
        accountId: 'acc-1',
        amount: -80.0,
        type: TransactionType.expense,
        frequency: RecurrenceFrequency.monthly,
        startDate: DateTime(2026, 7, 1),
        nextExecutionDate: DateTime(2026, 7, 20),
        createdAt: DateTime(2026, 7, 1),
        updatedAt: DateTime(2026, 7, 1),
      );

      final futureSchedule = RecurringSchedule(
        id: 'sch-future',
        title: 'Annual Car Insurance',
        accountId: 'acc-1',
        amount: -600.0,
        type: TransactionType.expense,
        frequency: RecurrenceFrequency.yearly,
        startDate: DateTime(2026, 7, 1),
        nextExecutionDate: DateTime(2026, 12, 1),
        createdAt: DateTime(2026, 7, 1),
        updatedAt: DateTime(2026, 7, 1),
      );

      final currentDate = DateTime(2026, 7, 22);
      final dueTransactions = RecurringExecutionEngine.generateDueTransactions(
        schedules: [dueSchedule, futureSchedule],
        currentDate: currentDate,
      );

      expect(dueTransactions.length, equals(1));
      expect(
          dueTransactions.first.description, equals('Internet Service Bill'));
      expect(dueTransactions.first.amount, equals(-80.0));
    });

    test('RecurringSchedule copyWith cleanly updates status and timestamps',
        () {
      final schedule = RecurringSchedule(
        id: 'sch-copy',
        title: 'Gym Membership',
        accountId: 'acc-1',
        amount: -30.0,
        type: TransactionType.expense,
        frequency: RecurrenceFrequency.monthly,
        startDate: DateTime(2026, 1, 1),
        nextExecutionDate: DateTime(2026, 8, 1),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final paused = schedule.copyWith(status: RecurringScheduleStatus.paused);
      expect(paused.status, equals(RecurringScheduleStatus.paused));
      expect(paused.title, equals('Gym Membership'));
    });
  });
}
