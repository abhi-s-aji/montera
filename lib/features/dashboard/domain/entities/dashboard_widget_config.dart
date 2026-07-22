import 'package:equatable/equatable.dart';

enum DashboardWidgetType {
  netWorthCard,
  balanceSummary,
  mtdIncome,
  mtdExpense,
  cashFlowChart,
  accountSummary,
  recentTransactions,
  topCategories,
  quickActions,
}

class DashboardWidgetConfig extends Equatable {
  final String id;
  final DashboardWidgetType type;
  final String title;
  final bool isVisible;
  final int sortOrder;

  const DashboardWidgetConfig({
    required this.id,
    required this.type,
    required this.title,
    this.isVisible = true,
    required this.sortOrder,
  });

  DashboardWidgetConfig copyWith({
    String? id,
    DashboardWidgetType? type,
    String? title,
    bool? isVisible,
    int? sortOrder,
  }) {
    return DashboardWidgetConfig(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      isVisible: isVisible ?? this.isVisible,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'isVisible': isVisible,
        'sortOrder': sortOrder,
      };

  factory DashboardWidgetConfig.fromJson(Map<String, dynamic> json) {
    return DashboardWidgetConfig(
      id: json['id'] as String,
      type: DashboardWidgetType.values.firstWhere((e) => e.name == json['type'],
          orElse: () => DashboardWidgetType.netWorthCard),
      title: json['title'] as String,
      isVisible: json['isVisible'] as bool? ?? true,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, type, title, isVisible, sortOrder];
}
