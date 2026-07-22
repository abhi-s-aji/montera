import 'package:flutter_test/flutter_test.dart';
import 'package:monetra/core/domain/entities/transaction.dart';
import 'package:monetra/features/analytics/domain/entities/analytics_summary.dart';
import 'package:monetra/features/reports/domain/entities/report_config.dart';
import 'package:monetra/features/reports/services/export_engine.dart';

void main() {
  group('Reports & Export Engine Unit Tests', () {
    const summary = AnalyticsSummary(
      totalIncome: 4000.0,
      totalExpenses: 1500.0,
      netSavings: 2500.0,
      savingsRate: 62.5,
      avgDailySpending: 50.0,
      avgMonthlySpending: 1500.0,
      highestExpense: 800.0,
      highestIncome: 4000.0,
      topCategoryName: 'Housing',
      topCategoryAmount: 800.0,
      totalTransactionCount: 2,
    );

    final transactions = [
      TransactionEntity(
        id: 'tx-1',
        accountId: 'acc-1',
        amount: 4000.0,
        type: TransactionType.income,
        date: DateTime(2026, 7, 1),
        description: 'Salary',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      TransactionEntity(
        id: 'tx-2',
        accountId: 'acc-1',
        amount: -800.0,
        type: TransactionType.expense,
        date: DateTime(2026, 7, 2),
        description: 'Apartment Rent',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    test('generateCsv generates valid CSV headers and rows', () {
      final csv = ExportEngine.generateCsv(
          summary: summary, transactions: transactions);

      expect(csv,
          contains('ID,Date,Description,Amount,Type,Status,Category,Tags'));
      expect(csv, contains('"Salary"'));
      expect(csv, contains('"Apartment Rent"'));
    });

    test('generateJson encodes clean structured JSON output', () {
      final jsonStr = ExportEngine.generateJson(
          summary: summary, transactions: transactions);

      expect(jsonStr, contains('"totalIncome": 4000.0'));
      expect(jsonStr, contains('"description": "Apartment Rent"'));
    });

    test('generateMarkdown formats GFM headers and table', () {
      final config = ReportConfig(
        id: 'rep-1',
        title: 'Monthly Summary',
        type: ReportType.income,
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );

      final md = ExportEngine.generateMarkdown(
          config: config, summary: summary, transactions: transactions);

      expect(md, contains('# Monthly Summary'));
      expect(md, contains('Total Income:'));
      expect(md, contains('| Date | Description | Type | Amount |'));
    });
  });
}
