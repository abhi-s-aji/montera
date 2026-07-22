import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monetra/core/providers/category_providers.dart';
import 'package:monetra/core/providers/transaction_providers.dart';
import 'package:monetra/features/dashboard/domain/entities/dashboard_widget_config.dart';

// Dashboard layout widgets configuration state provider
final dashboardWidgetLayoutProvider =
    StateProvider<List<DashboardWidgetConfig>>((ref) {
  return const [
    DashboardWidgetConfig(
        id: 'w-networth',
        type: DashboardWidgetType.netWorthCard,
        title: 'Net Worth',
        sortOrder: 1),
    DashboardWidgetConfig(
        id: 'w-mtd-income',
        type: DashboardWidgetType.mtdIncome,
        title: 'Month-to-Date Income',
        sortOrder: 2),
    DashboardWidgetConfig(
        id: 'w-mtd-expense',
        type: DashboardWidgetType.mtdExpense,
        title: 'Month-to-Date Expenses',
        sortOrder: 3),
    DashboardWidgetConfig(
        id: 'w-cashflow',
        type: DashboardWidgetType.cashFlowChart,
        title: 'Net Worth Trajectory',
        sortOrder: 4),
    DashboardWidgetConfig(
        id: 'w-quickactions',
        type: DashboardWidgetType.quickActions,
        title: 'Quick Actions',
        sortOrder: 5),
    DashboardWidgetConfig(
        id: 'w-accounts',
        type: DashboardWidgetType.accountSummary,
        title: 'Accounts Summary',
        sortOrder: 6),
    DashboardWidgetConfig(
        id: 'w-recent-tx',
        type: DashboardWidgetType.recentTransactions,
        title: 'Recent Transactions',
        sortOrder: 7),
    DashboardWidgetConfig(
        id: 'w-top-categories',
        type: DashboardWidgetType.topCategories,
        title: 'Top Spending Categories',
        sortOrder: 8),
  ];
});

// Category Spending Distribution Calculation Provider
final topSpendingCategoriesProvider = Provider<Map<String, double>>((ref) {
  final transactionsAsync = ref.watch(transactionsStreamProvider);
  final categoriesAsync = ref.watch(categoriesStreamProvider);

  return transactionsAsync.when(
    data: (transactions) {
      final Map<String, double> categoryTotals = {};
      final categories = categoriesAsync.value ?? [];

      for (final tx in transactions) {
        if (tx.amount < 0 && tx.categoryId != null) {
          final catName = categories
              .firstWhere(
                (c) => c.id == tx.categoryId,
                orElse: () => categories.first,
              )
              .name;
          categoryTotals[catName] =
              (categoryTotals[catName] ?? 0) + tx.amount.abs();
        }
      }
      return categoryTotals;
    },
    loading: () => {},
    error: (_, __) => {},
  );
});
