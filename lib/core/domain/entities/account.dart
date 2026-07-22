import 'package:equatable/equatable.dart';

enum AccountType {
  cash,
  bank,
  savings,
  checking,
  creditCard,
  debitCard,
  digitalWallet,
  upiWallet,
  investment,
  loan,
  custom,
}

class Account extends Equatable {
  final String id;
  final String name;
  final String? description;
  final AccountType type;
  final String currency;
  final double openingBalance;
  final double balance;
  final String icon;
  final String colorHex;
  final String? institutionName;
  final String? accountNumberMasked;
  final String? notes;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final bool isDeleted;

  const Account({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.currency,
    required this.openingBalance,
    required this.balance,
    required this.icon,
    required this.colorHex,
    this.institutionName,
    this.accountNumberMasked,
    this.notes,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
    this.version = 1,
    this.isDeleted = false,
  });

  Account copyWith({
    String? id,
    String? name,
    String? description,
    AccountType? type,
    String? currency,
    double? openingBalance,
    double? balance,
    String? icon,
    String? colorHex,
    String? institutionName,
    String? accountNumberMasked,
    String? notes,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    bool? isDeleted,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      currency: currency ?? this.currency,
      openingBalance: openingBalance ?? this.openingBalance,
      balance: balance ?? this.balance,
      icon: icon ?? this.icon,
      colorHex: colorHex ?? this.colorHex,
      institutionName: institutionName ?? this.institutionName,
      accountNumberMasked: accountNumberMasked ?? this.accountNumberMasked,
      notes: notes ?? this.notes,
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
        'currency': currency,
        'openingBalance': openingBalance,
        'balance': balance,
        'icon': icon,
        'colorHex': colorHex,
        'institutionName': institutionName,
        'accountNumberMasked': accountNumberMasked,
        'notes': notes,
        'isArchived': isArchived,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'version': version,
        'isDeleted': isDeleted,
      };

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: AccountType.values.firstWhere((e) => e.name == json['type'],
          orElse: () => AccountType.checking),
      currency: json['currency'] as String? ?? 'USD',
      openingBalance: (json['openingBalance'] as num? ?? 0).toDouble(),
      balance: (json['balance'] as num? ?? 0).toDouble(),
      icon: json['icon'] as String? ?? 'account_balance',
      colorHex: json['colorHex'] as String? ?? '#2196F3',
      institutionName: json['institutionName'] as String?,
      accountNumberMasked: json['accountNumberMasked'] as String?,
      notes: json['notes'] as String?,
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
        currency,
        openingBalance,
        balance,
        icon,
        colorHex,
        institutionName,
        accountNumberMasked,
        notes,
        isArchived,
        createdAt,
        updatedAt,
        version,
        isDeleted,
      ];
}
