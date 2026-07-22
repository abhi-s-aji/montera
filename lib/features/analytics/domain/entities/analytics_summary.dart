import 'package:equatable/equatable.dart';

class AnalyticsSummary extends Equatable {
  final double totalIncome;
  final double totalExpenses;
  final double netSavings;
  final double savingsRate; // percentage 0.0 - 100.0
  final double avgDailySpending;
  final double avgMonthlySpending;
  final double highestExpense;
  final double highestIncome;
  final String topCategoryName;
  final double topCategoryAmount;
  final int totalTransactionCount;

  const AnalyticsSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.netSavings,
    required this.savingsRate,
    required this.avgDailySpending,
    required this.avgMonthlySpending,
    required this.highestExpense,
    required this.highestIncome,
    required this.topCategoryName,
    required this.topCategoryAmount,
    required this.totalTransactionCount,
  });

  @override
  List<Object?> get props => [
        totalIncome,
        totalExpenses,
        netSavings,
        savingsRate,
        avgDailySpending,
        avgMonthlySpending,
        highestExpense,
        highestIncome,
        topCategoryName,
        topCategoryAmount,
        totalTransactionCount,
      ];
}

class CategorySpendingShare extends Equatable {
  final String categoryName;
  final double totalAmount;
  final double percentage; // 0.0 - 100.0

  const CategorySpendingShare({
    required this.categoryName,
    required this.totalAmount,
    required this.percentage,
  });

  @override
  List<Object?> get props => [categoryName, totalAmount, percentage];
}
