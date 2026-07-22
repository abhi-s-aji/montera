import 'package:equatable/equatable.dart';

enum CategoryType { income, expense, transfer, system }

class Category extends Equatable {
  final String id;
  final String name;
  final String? description;
  final CategoryType type;
  final String? parentCategoryId;
  final String icon;
  final String colorHex;
  final int sortOrder;
  final bool isDefaultBudget;
  final String? defaultMerchantId;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final bool isDeleted;

  const Category({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    this.parentCategoryId,
    required this.icon,
    required this.colorHex,
    this.sortOrder = 0,
    this.isDefaultBudget = false,
    this.defaultMerchantId,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
    this.version = 1,
    this.isDeleted = false,
  });

  Category copyWith({
    String? id,
    String? name,
    String? description,
    CategoryType? type,
    String? parentCategoryId,
    String? icon,
    String? colorHex,
    int? sortOrder,
    bool? isDefaultBudget,
    String? defaultMerchantId,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    bool? isDeleted,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      icon: icon ?? this.icon,
      colorHex: colorHex ?? this.colorHex,
      sortOrder: sortOrder ?? this.sortOrder,
      isDefaultBudget: isDefaultBudget ?? this.isDefaultBudget,
      defaultMerchantId: defaultMerchantId ?? this.defaultMerchantId,
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
        'parentCategoryId': parentCategoryId,
        'icon': icon,
        'colorHex': colorHex,
        'sortOrder': sortOrder,
        'isDefaultBudget': isDefaultBudget,
        'defaultMerchantId': defaultMerchantId,
        'isArchived': isArchived,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'version': version,
        'isDeleted': isDeleted,
      };

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: CategoryType.values.firstWhere((e) => e.name == json['type'],
          orElse: () => CategoryType.expense),
      parentCategoryId: json['parentCategoryId'] as String?,
      icon: json['icon'] as String? ?? 'category',
      colorHex: json['colorHex'] as String? ?? '#4CAF50',
      sortOrder: json['sortOrder'] as int? ?? 0,
      isDefaultBudget: json['isDefaultBudget'] as bool? ?? false,
      defaultMerchantId: json['defaultMerchantId'] as String?,
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
        parentCategoryId,
        icon,
        colorHex,
        sortOrder,
        isDefaultBudget,
        defaultMerchantId,
        isArchived,
        createdAt,
        updatedAt,
        version,
        isDeleted,
      ];
}
