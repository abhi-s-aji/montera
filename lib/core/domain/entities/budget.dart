import 'package:equatable/equatable.dart';

enum BudgetPeriod { weekly, monthly, yearly, custom, rolling }

enum BudgetType { category, account, tag, global }

class Budget extends Equatable {
  final String id;
  final String name;
  final String? description;
  final BudgetType type;
  final String? categoryId;
  final String? accountId;
  final String? tag;
  final String currency;
  final double amount;
  final BudgetPeriod period;
  final double warningThreshold; // e.g. 0.8 (80%)
  final double criticalThreshold; // e.g. 1.0 (100%)
  final bool carryForward;
  final DateTime startDate;
  final DateTime endDate;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final bool isDeleted;

  const Budget({
    required this.id,
    required this.name,
    this.description,
    this.type = BudgetType.category,
    this.categoryId,
    this.accountId,
    this.tag,
    this.currency = 'USD',
    required this.amount,
    required this.period,
    this.warningThreshold = 0.8,
    this.criticalThreshold = 1.0,
    this.carryForward = false,
    required this.startDate,
    required this.endDate,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
    this.version = 1,
    this.isDeleted = false,
  });

  Budget copyWith({
    String? id,
    String? name,
    String? description,
    BudgetType? type,
    String? categoryId,
    String? accountId,
    String? tag,
    String? currency,
    double? amount,
    BudgetPeriod? period,
    double? warningThreshold,
    double? criticalThreshold,
    bool? carryForward,
    DateTime? startDate,
    DateTime? endDate,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    bool? isDeleted,
  }) {
    return Budget(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      tag: tag ?? this.tag,
      currency: currency ?? this.currency,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      warningThreshold: warningThreshold ?? this.warningThreshold,
      criticalThreshold: criticalThreshold ?? this.criticalThreshold,
      carryForward: carryForward ?? this.carryForward,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'type': type.name,
        'categoryId': categoryId,
        'accountId': accountId,
        'tag': tag,
        'currency': currency,
        'amount': amount,
        'period': period.name,
        'warningThreshold': warningThreshold,
        'criticalThreshold': criticalThreshold,
        'carryForward': carryForward,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'isArchived': isArchived,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'version': version,
        'isDeleted': isDeleted,
      };

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: BudgetType.values.firstWhere((e) => e.name == json['type'],
          orElse: () => BudgetType.category),
      categoryId: json['categoryId'] as String?,
      accountId: json['accountId'] as String?,
      tag: json['tag'] as String?,
      currency: json['currency'] as String? ?? 'USD',
      amount: (json['amount'] as num? ?? 0).toDouble(),
      period: BudgetPeriod.values.firstWhere((e) => e.name == json['period'],
          orElse: () => BudgetPeriod.monthly),
      warningThreshold: (json['warningThreshold'] as num? ?? 0.8).toDouble(),
      criticalThreshold: (json['criticalThreshold'] as num? ?? 1.0).toDouble(),
      carryForward: json['carryForward'] as bool? ?? false,
      startDate: DateTime.parse(
          json['startDate'] as String? ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(
          json['endDate'] as String? ?? DateTime.now().toIso8601String()),
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
        name,
        description,
        type,
        categoryId,
        accountId,
        tag,
        currency,
        amount,
        period,
        warningThreshold,
        criticalThreshold,
        carryForward,
        startDate,
        endDate,
        isArchived,
        createdAt,
        updatedAt,
        version,
        isDeleted,
      ];
}

class BudgetProgressCalculation {
  final Budget budget;
  final double spentAmount;
  final double remainingAmount;
  final double progress;
  final bool isOverBudget;
  final double dailyAllowance;
  final int remainingDays;

  const BudgetProgressCalculation({
    required this.budget,
    required this.spentAmount,
    required this.remainingAmount,
    required this.progress,
    required this.isOverBudget,
    required this.dailyAllowance,
    required this.remainingDays,
  });
}
