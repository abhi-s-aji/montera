import 'package:equatable/equatable.dart';

enum GoalType {
  savings,
  debtReduction,
  emergencyFund,
  vacation,
  vehicle,
  home,
  investment,
  education,
  retirement,
  custom,
}

enum GoalStatus { inProgress, completed, paused, cancelled }

class Goal extends Equatable {
  final String id;
  final String title;
  final String? description;
  final GoalType type;
  final double targetAmount;
  final double currentAmount;
  final String currency;
  final String? linkedAccountId;
  final String? linkedBudgetId;
  final DateTime? targetDate;
  final int priority; // 1 (Highest) to 5 (Lowest)
  final String colorHex;
  final String icon;
  final GoalStatus status;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final bool isDeleted;

  const Goal({
    required this.id,
    required this.title,
    this.description,
    this.type = GoalType.savings,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.currency = 'USD',
    this.linkedAccountId,
    this.linkedBudgetId,
    this.targetDate,
    this.priority = 3,
    this.colorHex = '#10B981',
    this.icon = 'flag',
    this.status = GoalStatus.inProgress,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
    this.version = 1,
    this.isDeleted = false,
  });

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    GoalType? type,
    double? targetAmount,
    double? currentAmount,
    String? currency,
    String? linkedAccountId,
    String? linkedBudgetId,
    DateTime? targetDate,
    int? priority,
    String? colorHex,
    String? icon,
    GoalStatus? status,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    bool? isDeleted,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      currency: currency ?? this.currency,
      linkedAccountId: linkedAccountId ?? this.linkedAccountId,
      linkedBudgetId: linkedBudgetId ?? this.linkedBudgetId,
      targetDate: targetDate ?? this.targetDate,
      priority: priority ?? this.priority,
      colorHex: colorHex ?? this.colorHex,
      icon: icon ?? this.icon,
      status: status ?? this.status,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type.name,
        'targetAmount': targetAmount,
        'currentAmount': currentAmount,
        'currency': currency,
        'linkedAccountId': linkedAccountId,
        'linkedBudgetId': linkedBudgetId,
        'targetDate': targetDate?.toIso8601String(),
        'priority': priority,
        'colorHex': colorHex,
        'icon': icon,
        'status': status.name,
        'isArchived': isArchived,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'version': version,
        'isDeleted': isDeleted,
      };

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: GoalType.values.firstWhere((e) => e.name == json['type'],
          orElse: () => GoalType.savings),
      targetAmount: (json['targetAmount'] as num? ?? 0).toDouble(),
      currentAmount: (json['currentAmount'] as num? ?? 0).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      linkedAccountId: json['linkedAccountId'] as String?,
      linkedBudgetId: json['linkedBudgetId'] as String?,
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'] as String)
          : null,
      priority: json['priority'] as int? ?? 3,
      colorHex: json['colorHex'] as String? ?? '#10B981',
      icon: json['icon'] as String? ?? 'flag',
      status: GoalStatus.values.firstWhere((e) => e.name == json['status'],
          orElse: () => GoalStatus.inProgress),
      isArchived: json['isArchived'] as bool? ?? false,
      createdAt: DateTime.parse(
          json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updatedAt'] as String? ?? DateTime.now().toIso8601String()),
      version: json['version'] as int? ?? 1,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        targetAmount,
        currentAmount,
        currency,
        linkedAccountId,
        linkedBudgetId,
        targetDate,
        priority,
        colorHex,
        icon,
        status,
        isArchived,
        createdAt,
        updatedAt,
        version,
        isDeleted,
      ];
}

class GoalProgressCalculation {
  final Goal goal;
  final double remainingAmount;
  final double progressPercentage; // 0.0 to 1.0
  final int remainingDays;
  final double requiredDailyContribution;
  final double requiredMonthlyContribution;

  const GoalProgressCalculation({
    required this.goal,
    required this.remainingAmount,
    required this.progressPercentage,
    required this.remainingDays,
    required this.requiredDailyContribution,
    required this.requiredMonthlyContribution,
  });
}
