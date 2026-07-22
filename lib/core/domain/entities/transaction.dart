import 'package:equatable/equatable.dart';

enum TransactionStatus { completed, pending, cancelled, uncleared }

enum TransactionType { expense, income, transfer, adjustment }

class TransactionSplitLine extends Equatable {
  final String categoryId;
  final double amount;
  final String? notes;

  const TransactionSplitLine({
    required this.categoryId,
    required this.amount,
    this.notes,
  });

  @override
  List<Object?> get props => [categoryId, amount, notes];
}

class TransactionEntity extends Equatable {
  final String id;
  final String accountId;
  final String? destinationAccountId;
  final String? categoryId;
  final String? merchantId;
  final double amount;
  final String currency;
  final double? exchangeRate;
  final TransactionType type;
  final DateTime date;
  final String? timezone;
  final TransactionStatus status;
  final String description;
  final String? notes;
  final List<String> tags;
  final List<String> attachmentPaths;
  final List<TransactionSplitLine> splits;
  final String? recurringTemplateId;
  final bool isRecurring;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final bool isDeleted;

  const TransactionEntity({
    required this.id,
    required this.accountId,
    this.destinationAccountId,
    this.categoryId,
    this.merchantId,
    required this.amount,
    this.currency = 'USD',
    this.exchangeRate,
    this.type = TransactionType.expense,
    required this.date,
    this.timezone,
    this.status = TransactionStatus.completed,
    required this.description,
    this.notes,
    this.tags = const [],
    this.attachmentPaths = const [],
    this.splits = const [],
    this.recurringTemplateId,
    this.isRecurring = false,
    required this.createdAt,
    required this.updatedAt,
    this.version = 1,
    this.isDeleted = false,
  });

  bool get isTransfer =>
      type == TransactionType.transfer ||
      (destinationAccountId != null && destinationAccountId!.isNotEmpty);

  TransactionEntity copyWith({
    String? id,
    String? accountId,
    String? destinationAccountId,
    String? categoryId,
    String? merchantId,
    double? amount,
    String? currency,
    double? exchangeRate,
    TransactionType? type,
    DateTime? date,
    String? timezone,
    TransactionStatus? status,
    String? description,
    String? notes,
    List<String>? tags,
    List<String>? attachmentPaths,
    List<TransactionSplitLine>? splits,
    String? recurringTemplateId,
    bool? isRecurring,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    bool? isDeleted,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      destinationAccountId: destinationAccountId ?? this.destinationAccountId,
      categoryId: categoryId ?? this.categoryId,
      merchantId: merchantId ?? this.merchantId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      type: type ?? this.type,
      date: date ?? this.date,
      timezone: timezone ?? this.timezone,
      status: status ?? this.status,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      attachmentPaths: attachmentPaths ?? this.attachmentPaths,
      splits: splits ?? this.splits,
      recurringTemplateId: recurringTemplateId ?? this.recurringTemplateId,
      isRecurring: isRecurring ?? this.isRecurring,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'accountId': accountId,
        'destinationAccountId': destinationAccountId,
        'categoryId': categoryId,
        'merchantId': merchantId,
        'amount': amount,
        'currency': currency,
        'exchangeRate': exchangeRate,
        'type': type.name,
        'date': date.toIso8601String(),
        'timezone': timezone,
        'status': status.name,
        'description': description,
        'notes': notes,
        'tags': tags,
        'attachmentPaths': attachmentPaths,
        'recurringTemplateId': recurringTemplateId,
        'isRecurring': isRecurring,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'version': version,
        'isDeleted': isDeleted,
      };

  factory TransactionEntity.fromJson(Map<String, dynamic> json) {
    return TransactionEntity(
      id: json['id'] as String,
      accountId: json['accountId'] as String,
      destinationAccountId: json['destinationAccountId'] as String?,
      categoryId: json['categoryId'] as String?,
      merchantId: json['merchantId'] as String?,
      amount: (json['amount'] as num? ?? 0).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      exchangeRate: (json['exchangeRate'] as num?)?.toDouble(),
      type: TransactionType.values.firstWhere((e) => e.name == json['type'],
          orElse: () => TransactionType.expense),
      date: DateTime.parse(
          json['date'] as String? ?? DateTime.now().toIso8601String()),
      timezone: json['timezone'] as String?,
      status: TransactionStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => TransactionStatus.completed),
      description: json['description'] as String? ?? '',
      notes: json['notes'] as String?,
      tags: List<String>.from(json['tags'] as List? ?? []),
      attachmentPaths:
          List<String>.from(json['attachmentPaths'] as List? ?? []),
      recurringTemplateId: json['recurringTemplateId'] as String?,
      isRecurring: json['isRecurring'] as bool? ?? false,
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
        accountId,
        destinationAccountId,
        categoryId,
        merchantId,
        amount,
        currency,
        exchangeRate,
        type,
        date,
        timezone,
        status,
        description,
        notes,
        tags,
        attachmentPaths,
        splits,
        recurringTemplateId,
        isRecurring,
        createdAt,
        updatedAt,
        version,
        isDeleted,
      ];
}
