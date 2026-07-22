import 'package:equatable/equatable.dart';
import 'package:monetra/core/domain/entities/transaction.dart';

enum RecurrenceFrequency {
  daily,
  weekly,
  biweekly,
  monthly,
  quarterly,
  yearly,
  custom
}

enum RecurringScheduleStatus { active, paused, completed, cancelled }

class RecurringSchedule extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String accountId;
  final String? categoryId;
  final double amount;
  final TransactionType type;
  final RecurrenceFrequency frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime nextExecutionDate;
  final DateTime? previousExecutionDate;
  final RecurringScheduleStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final bool isDeleted;

  const RecurringSchedule({
    required this.id,
    required this.title,
    this.description,
    required this.accountId,
    this.categoryId,
    required this.amount,
    required this.type,
    required this.frequency,
    required this.startDate,
    this.endDate,
    required this.nextExecutionDate,
    this.previousExecutionDate,
    this.status = RecurringScheduleStatus.active,
    required this.createdAt,
    required this.updatedAt,
    this.version = 1,
    this.isDeleted = false,
  });

  RecurringSchedule copyWith({
    String? id,
    String? title,
    String? description,
    String? accountId,
    String? categoryId,
    double? amount,
    TransactionType? type,
    RecurrenceFrequency? frequency,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? nextExecutionDate,
    DateTime? previousExecutionDate,
    RecurringScheduleStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    bool? isDeleted,
  }) {
    return RecurringSchedule(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      nextExecutionDate: nextExecutionDate ?? this.nextExecutionDate,
      previousExecutionDate:
          previousExecutionDate ?? this.previousExecutionDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        accountId,
        categoryId,
        amount,
        type,
        frequency,
        startDate,
        endDate,
        nextExecutionDate,
        previousExecutionDate,
        status,
        createdAt,
        updatedAt,
        version,
        isDeleted,
      ];
}

class AutomationLog extends Equatable {
  final String id;
  final String scheduleId;
  final String scheduleTitle;
  final DateTime executedAt;
  final String generatedTransactionId;
  final String status; // success, skipped, failed
  final String message;

  const AutomationLog({
    required this.id,
    required this.scheduleId,
    required this.scheduleTitle,
    required this.executedAt,
    required this.generatedTransactionId,
    required this.status,
    required this.message,
  });

  @override
  List<Object?> get props => [
        id,
        scheduleId,
        scheduleTitle,
        executedAt,
        generatedTransactionId,
        status,
        message,
      ];
}
