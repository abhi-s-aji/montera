import 'package:equatable/equatable.dart';

enum ExportFormat { pdf, csv, json, markdown, html }

enum ReportType {
  income,
  expense,
  cashFlow,
  netWorth,
  budgetSummary,
  taxSummary,
  custom,
}

class ReportConfig extends Equatable {
  final String id;
  final String title;
  final ReportType type;
  final DateTime startDate;
  final DateTime endDate;
  final String? accountId;
  final String? categoryId;
  final bool includeCharts;

  const ReportConfig({
    required this.id,
    required this.title,
    required this.type,
    required this.startDate,
    required this.endDate,
    this.accountId,
    this.categoryId,
    this.includeCharts = true,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        type,
        startDate,
        endDate,
        accountId,
        categoryId,
        includeCharts
      ];
}
