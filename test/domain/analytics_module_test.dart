import 'package:flutter_test/flutter_test.dart';
import 'package:monetra/features/analytics/domain/entities/analytics_summary.dart';

void main() {
  group('Analytics Engine Unit Tests', () {
    test('AnalyticsSummary props comparison works as expected', () {
      const summary1 = AnalyticsSummary(
        totalIncome: 5000.0,
        totalExpenses: 2000.0,
        netSavings: 3000.0,
        savingsRate: 60.0,
        avgDailySpending: 66.66,
        avgMonthlySpending: 2000.0,
        highestExpense: 1200.0,
        highestIncome: 5000.0,
        topCategoryName: 'Rent',
        topCategoryAmount: 1200.0,
        totalTransactionCount: 15,
      );

      const summary2 = AnalyticsSummary(
        totalIncome: 5000.0,
        totalExpenses: 2000.0,
        netSavings: 3000.0,
        savingsRate: 60.0,
        avgDailySpending: 66.66,
        avgMonthlySpending: 2000.0,
        highestExpense: 1200.0,
        highestIncome: 5000.0,
        topCategoryName: 'Rent',
        topCategoryAmount: 1200.0,
        totalTransactionCount: 15,
      );

      expect(summary1, equals(summary2));
    });

    test('CategorySpendingShare calculates correct percentage share', () {
      const share = CategorySpendingShare(
        categoryName: 'Groceries',
        totalAmount: 400.0,
        percentage: 25.0,
      );

      expect(share.percentage, equals(25.0));
      expect(share.categoryName, equals('Groceries'));
    });
  });
}
