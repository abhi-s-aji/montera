import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monetra/core/domain/entities/recurring_schedule.dart';
import 'package:monetra/core/domain/entities/transaction.dart';
import 'package:monetra/features/automation/services/recurring_engine_services.dart';

final mockSchedulesList = [
  RecurringSchedule(
    id: 'sch-1',
    title: 'Monthly Apartment Rent',
    accountId: 'acc-checking',
    categoryId: 'cat-housing',
    amount: -1200.0,
    type: TransactionType.expense,
    frequency: RecurrenceFrequency.monthly,
    startDate: DateTime(2026, 1, 1),
    nextExecutionDate: DateTime(2026, 8, 1),
    status: RecurringScheduleStatus.active,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  ),
  RecurringSchedule(
    id: 'sch-2',
    title: 'Biweekly Salary Direct Deposit',
    accountId: 'acc-checking',
    categoryId: 'cat-income',
    amount: 2400.0,
    type: TransactionType.income,
    frequency: RecurrenceFrequency.biweekly,
    startDate: DateTime(2026, 1, 1),
    nextExecutionDate: DateTime(2026, 7, 30),
    status: RecurringScheduleStatus.active,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  ),
];

final recurringScheduleListProvider =
    StateProvider<List<RecurringSchedule>>((ref) => mockSchedulesList);

final upcomingForecastPreviewProvider =
    Provider<List<TransactionEntity>>((ref) {
  final schedules = ref.watch(recurringScheduleListProvider);
  final forecastDate = DateTime.now().add(const Duration(days: 30));
  return RecurringExecutionEngine.generateDueTransactions(
    schedules: schedules,
    currentDate: forecastDate,
  );
});

final automationLogListProvider =
    StateProvider<List<AutomationLog>>((ref) => []);
