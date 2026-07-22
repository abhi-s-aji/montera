import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monetra/core/domain/entities/transaction.dart';
import 'package:monetra/core/providers/category_providers.dart';
import 'package:monetra/core/providers/transaction_providers.dart';
import 'package:monetra/features/analytics/domain/entities/analytics_summary.dart';

enum AnalyticsTimeRange { thisMonth, lastMonth, thisQuarter, thisYear, allTime }

final analyticsTimeRangeProvider =
    StateProvider<AnalyticsTimeRange>((ref) => AnalyticsTimeRange.thisMonth);

// Filtered Transactions by Date Range
final analyticsTransactionsProvider = Provider<List<TransactionEntity>>((ref) {
  final transactionsAsync = ref.watch(transactionsStreamProvider);
  final range = ref.watch(analyticsTimeRangeProvider);
  final now = DateTime.now();

  return transactionsAsync.when(
    data: (transactions) {
      return transactions.where((t) {
        switch (range) {
          case AnalyticsTimeRange.thisMonth:
            return t.date.month == now.month && t.date.year == now.year;
          case AnalyticsTimeRange.lastMonth:
            final lastMonthDate = DateTime(now.year, now.month - 1, 1);
            return t.date.month == lastMonthDate.month &&
                t.date.year == lastMonthDate.year;
          case AnalyticsTimeRange.thisQuarter:
            final quarterStartMonth = ((now.month - 1) ~/ 3) * 3 + 1;
            return t.date.month >= quarterStartMonth && t.date.year == now.year;
          case AnalyticsTimeRange.thisYear:
            return t.date.year == now.year;
          case AnalyticsTimeRange.allTime:
            return true;
        }
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Analytics Summary Calculation Engine
final analyticsSummaryProvider = Provider<AnalyticsSummary>((ref) {
  final transactions = ref.watch(analyticsTransactionsProvider);
  final categoriesAsync = ref.watch(categoriesStreamProvider);
  final categories = categoriesAsync.value ?? [];

  double income = 0;
  double expenses = 0;
  double maxExpense = 0;
  double maxIncome = 0;
  final Map<String, double> categoryMap = {};

  for (final t in transactions) {
    if (t.type == TransactionType.transfer) continue;

    if (t.amount > 0) {
      income += t.amount;
      if (t.amount > maxIncome) maxIncome = t.amount;
    } else if (t.amount < 0) {
      final absAmt = t.amount.abs();
      expenses += absAmt;
      if (absAmt > maxExpense) maxExpense = absAmt;

      if (t.categoryId != null) {
        final catName = categories
            .firstWhere(
              (c) => c.id == t.categoryId,
              orElse: () => categories.first,
            )
            .name;
        categoryMap[catName] = (categoryMap[catName] ?? 0) + absAmt;
      }
    }
  }

  final netSavings = income - expenses;
  final savingsRate =
      income > 0 ? ((netSavings / income) * 100).clamp(0.0, 100.0) : 0.0;
  final days = 30; // Standard month basis
  final avgDaily = expenses / days;

  var topCatName = 'N/A';
  var topCatAmt = 0.0;
  if (categoryMap.isNotEmpty) {
    final sortedCats = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    topCatName = sortedCats.first.key;
    topCatAmt = sortedCats.first.value;
  }

  return AnalyticsSummary(
    totalIncome: income,
    totalExpenses: expenses,
    netSavings: netSavings,
    savingsRate: savingsRate,
    avgDailySpending: avgDaily,
    avgMonthlySpending: expenses,
    highestExpense: maxExpense,
    highestIncome: maxIncome,
    topCategoryName: topCatName,
    topCategoryAmount: topCatAmt,
    totalTransactionCount: transactions.length,
  );
});

// Category Spending Distribution Breakdown
final categorySpendingBreakdownProvider =
    Provider<List<CategorySpendingShare>>((ref) {
  final summary = ref.watch(analyticsSummaryProvider);
  final transactions = ref.watch(analyticsTransactionsProvider);
  final categoriesAsync = ref.watch(categoriesStreamProvider);
  final categories = categoriesAsync.value ?? [];

  if (summary.totalExpenses <= 0) return [];

  final Map<String, double> categoryMap = {};
  for (final t in transactions) {
    if (t.amount < 0 &&
        t.type != TransactionType.transfer &&
        t.categoryId != null) {
      final catName = categories
          .firstWhere(
            (c) => c.id == t.categoryId,
            orElse: () => categories.first,
          )
          .name;
      categoryMap[catName] = (categoryMap[catName] ?? 0) + t.amount.abs();
    }
  }

  final totalExp = summary.totalExpenses;
  final shares = categoryMap.entries.map((e) {
    return CategorySpendingShare(
      categoryName: e.key,
      totalAmount: e.value,
      percentage: (e.value / totalExp) * 100,
    );
  }).toList();

  final sortedShares = List<CategorySpendingShare>.from(shares);
  sortedShares.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
  return sortedShares;
});
