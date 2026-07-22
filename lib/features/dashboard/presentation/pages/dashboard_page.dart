import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:monetra/core/providers/account_providers.dart';
import 'package:monetra/core/providers/transaction_providers.dart';
import 'package:monetra/core/theme/monetra_colors.dart';
import 'package:monetra/core/utils/currency_formatter.dart';
import 'package:monetra/core/widgets/monetra_card.dart';
import 'package:monetra/core/widgets/monetra_chart.dart';
import 'package:monetra/core/widgets/stat_card.dart';
import 'package:monetra/features/accounts/presentation/widgets/account_editor_dialog.dart';
import 'package:monetra/features/categories/presentation/widgets/category_editor_dialog.dart';
import 'package:monetra/features/dashboard/domain/entities/dashboard_widget_config.dart';
import 'package:monetra/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:monetra/features/dashboard/presentation/widgets/customize_dashboard_dialog.dart';
import 'package:monetra/features/transactions/presentation/widgets/transaction_editor_dialog.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  Widget _buildWidgetCard(
      BuildContext context, WidgetRef ref, DashboardWidgetConfig widgetConfig) {
    final theme = Theme.of(context);
    final netWorth = ref.watch(totalNetWorthProvider);
    final mtdIncome = ref.watch(monthToDateIncomeProvider);
    final mtdExpense = ref.watch(monthToDateExpenseProvider);
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final accountsAsync = ref.watch(accountsStreamProvider);
    final topCategories = ref.watch(topSpendingCategoriesProvider);

    final chartData = [
      18200.0,
      18500.0,
      19100.0,
      18900.0,
      19800.0,
      19400.0,
      19809.75
    ];

    switch (widgetConfig.type) {
      case DashboardWidgetType.netWorthCard:
        return StatCard(
          title: 'Net Worth',
          value: CurrencyFormatter.format(netWorth),
          subtitle: 'Active account total',
          icon: Icons.account_balance_wallet_rounded,
          iconColor: theme.colorScheme.primary,
        );

      case DashboardWidgetType.mtdIncome:
        return StatCard(
          title: 'Month-to-Date Income',
          value: CurrencyFormatter.format(mtdIncome),
          subtitle: 'Earned this month',
          icon: Icons.arrow_downward_rounded,
          iconColor: MonetraColors.incomeGreen,
        );

      case DashboardWidgetType.mtdExpense:
        return StatCard(
          title: 'Month-to-Date Expenses',
          value: CurrencyFormatter.format(mtdExpense),
          subtitle: 'Spent this month',
          icon: Icons.arrow_upward_rounded,
          iconColor: MonetraColors.expenseRed,
        );

      case DashboardWidgetType.cashFlowChart:
        return MonetraCard(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Net Worth Trajectory',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.textTheme.bodyLarge?.color),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '30-day cumulative financial trajectory',
                        style: TextStyle(
                            fontSize: 12,
                            color: theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.dividerColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('30 Days',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: theme.textTheme.bodyMedium?.color)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              MonetraChart(
                  dataPoints: chartData, lineColor: theme.colorScheme.primary),
            ],
          ),
        );

      case DashboardWidgetType.quickActions:
        return MonetraCard(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Quick Workspace Actions',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => TransactionEditorDialog.show(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Entry'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => AccountEditorDialog.show(context),
                    icon: const Icon(Icons.account_balance_outlined, size: 16),
                    label: const Text('New Account'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => CategoryEditorDialog.show(context),
                    icon: const Icon(Icons.category_outlined, size: 16),
                    label: const Text('New Category'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/settings'),
                    icon: const Icon(Icons.download_rounded, size: 16),
                    label: const Text('Export Backup'),
                  ),
                ],
              ),
            ],
          ),
        );

      case DashboardWidgetType.recentTransactions:
        return MonetraCard(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Recent Transactions',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color)),
              const SizedBox(height: 16),
              transactionsAsync.when(
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child:
                          Center(child: Text('No transactions recorded yet')),
                    );
                  }
                  final recent = transactions.take(5).toList();
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recent.length,
                    separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: theme.dividerColor.withValues(alpha: 0.3)),
                    itemBuilder: (context, index) {
                      final tx = recent[index];
                      final isExpense = tx.amount < 0;
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 4),
                        leading: CircleAvatar(
                          backgroundColor: (isExpense
                                  ? MonetraColors.expenseRed
                                  : MonetraColors.incomeGreen)
                              .withValues(alpha: 0.12),
                          child: Icon(
                            isExpense
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            color: isExpense
                                ? MonetraColors.expenseRed
                                : MonetraColors.incomeGreen,
                            size: 18,
                          ),
                        ),
                        title: Text(tx.description,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: Text(
                          '${tx.date.day}/${tx.date.month}/${tx.date.year}${tx.notes != null ? ' • ${tx.notes}' : ''}',
                          style: TextStyle(
                              fontSize: 12,
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withValues(alpha: 0.6)),
                        ),
                        trailing: Text(
                          CurrencyFormatter.format(tx.amount, showSign: true),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isExpense
                                ? theme.textTheme.bodyLarge?.color
                                : MonetraColors.incomeGreen,
                          ),
                        ),
                        onTap: () => TransactionEditorDialog.show(context,
                            transaction: tx),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text('Error loading transactions: $err'),
              ),
            ],
          ),
        );

      case DashboardWidgetType.accountSummary:
        return MonetraCard(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Accounts Overview',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color)),
              const SizedBox(height: 12),
              accountsAsync.when(
                data: (accounts) {
                  if (accounts.isEmpty)
                    return const Text('No active accounts.');
                  return Column(
                    children: accounts.take(4).map((acc) {
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(acc.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(acc.type.name.toUpperCase(),
                            style: const TextStyle(fontSize: 10)),
                        trailing: Text(
                          CurrencyFormatter.format(acc.balance,
                              currency: acc.currency),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
            ],
          ),
        );

      case DashboardWidgetType.topCategories:
        return MonetraCard(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Top Spending Categories',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color)),
              const SizedBox(height: 12),
              if (topCategories.isEmpty)
                const Text('No category expenses recorded yet.')
              else
                Column(
                  children: topCategories.entries.take(4).map((entry) {
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(entry.key,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      trailing: Text(CurrencyFormatter.format(entry.value),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    );
                  }).toList(),
                ),
            ],
          ),
        );

      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final widgetLayout = ref.watch(dashboardWidgetLayoutProvider);
    final visibleWidgets = widgetLayout.where((w) => w.isVisible).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final statCards = visibleWidgets
        .where((w) =>
            w.type == DashboardWidgetType.netWorthCard ||
            w.type == DashboardWidgetType.mtdIncome ||
            w.type == DashboardWidgetType.mtdExpense)
        .toList();

    final blockWidgets = visibleWidgets
        .where((w) =>
            w.type != DashboardWidgetType.netWorthCard &&
            w.type != DashboardWidgetType.mtdIncome &&
            w.type != DashboardWidgetType.mtdExpense)
        .toList();

    final isMobile = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) ...[
            Text(
              'Workspace Overview',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Offline. Private. Yours.',
              style: TextStyle(
                fontSize: 13,
                color: theme.textTheme.bodyMedium?.color
                    ?.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => CustomizeDashboardDialog.show(context),
                  icon: const Icon(Icons.dashboard_customize_outlined,
                      size: 16),
                  label: const Text('Customize'),
                ),
                ElevatedButton.icon(
                  onPressed: () => TransactionEditorDialog.show(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Entry'),
                ),
              ],
            ),
          ] else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Workspace Overview',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Offline. Private. Yours.',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textTheme.bodyMedium?.color
                            ?.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => CustomizeDashboardDialog.show(context),
                      icon: const Icon(Icons.dashboard_customize_outlined,
                          size: 16),
                      label: const Text('Customize'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => TransactionEditorDialog.show(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Entry'),
                    ),
                  ],
                ),
              ],
            ),
          const SizedBox(height: 24),
          if (statCards.isNotEmpty)
            if (isMobile)
              Column(
                children: statCards.map((w) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildWidgetCard(context, ref, w),
                  );
                }).toList(),
              )
            else
              Row(
                children: statCards.map((w) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: _buildWidgetCard(context, ref, w),
                    ),
                  );
                }).toList(),
              ),
          const SizedBox(height: 24),
          ...blockWidgets.map((w) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: _buildWidgetCard(context, ref, w),
            );
          }),
        ],
      ),
    );
  }
}
