import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monetra/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:monetra/features/reports/domain/entities/report_config.dart';
import 'package:monetra/features/reports/services/export_engine.dart';

final selectedReportFormatProvider =
    StateProvider<ExportFormat>((ref) => ExportFormat.markdown);
final selectedReportTypeProvider =
    StateProvider<ReportType>((ref) => ReportType.income);

final generatedExportContentProvider = Provider<String>((ref) {
  final format = ref.watch(selectedReportFormatProvider);
  final type = ref.watch(selectedReportTypeProvider);
  final summary = ref.watch(analyticsSummaryProvider);
  final transactions = ref.watch(analyticsTransactionsProvider);

  final config = ReportConfig(
    id: 'report-custom',
    title: '${type.name.toUpperCase()} Financial Statement',
    type: type,
    startDate: DateTime.now().subtract(const Duration(days: 30)),
    endDate: DateTime.now(),
  );

  switch (format) {
    case ExportFormat.pdf:
    case ExportFormat.markdown:
      return ExportEngine.generateMarkdown(
          config: config, summary: summary, transactions: transactions);
    case ExportFormat.csv:
      return ExportEngine.generateCsv(
          summary: summary, transactions: transactions);
    case ExportFormat.json:
      return ExportEngine.generateJson(
          summary: summary, transactions: transactions);
    case ExportFormat.html:
      return ExportEngine.generateHtml(
          config: config, summary: summary, transactions: transactions);
  }
});
