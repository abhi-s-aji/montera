import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/monetra_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/monetra_card.dart';
import '../../../../core/widgets/stat_card.dart';
import 'package:monetra/features/analytics/presentation/providers/analytics_providers.dart';

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final summary = ref.watch(analyticsSummaryProvider);
    final categoryBreakdown = ref.watch(categorySpendingBreakdownProvider);
    final selectedRange = ref.watch(analyticsTimeRangeProvider);

    final isMobile = MediaQuery.of(context).size.width < 600;

    final filterChips = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          label: const Text('This Month'),
          selected: selectedRange == AnalyticsTimeRange.thisMonth,
          onSelected: (_) => ref
              .read(analyticsTimeRangeProvider.notifier)
              .state = AnalyticsTimeRange.thisMonth,
        ),
        ChoiceChip(
          label: const Text('This Quarter'),
          selected: selectedRange == AnalyticsTimeRange.thisQuarter,
          onSelected: (_) => ref
              .read(analyticsTimeRangeProvider.notifier)
              .state = AnalyticsTimeRange.thisQuarter,
        ),
        ChoiceChip(
          label: const Text('This Year'),
          selected: selectedRange == AnalyticsTimeRange.thisYear,
          onSelected: (_) => ref
              .read(analyticsTimeRangeProvider.notifier)
              .state = AnalyticsTimeRange.thisYear,
        ),
      ],
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) ...[
            Text(
              'Financial Analytics & Insights',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Offline cash flow velocity & insights',
              style: TextStyle(
                fontSize: 13,
                color: theme.textTheme.bodyMedium?.color
                    ?.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [filterChips],
              ),
            ),
          ] else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Financial Analytics & Insights',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Offline cash flow velocity, savings rate, and category distribution',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textTheme.bodyMedium?.color
                            ?.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                // Time Range Selector Chips
                filterChips,
              ],
            ),
          const SizedBox(height: 24),
          // Metric Cards Row
          if (isMobile)
            Column(
              children: [
                StatCard(
                  title: 'Total Income',
                  value: CurrencyFormatter.format(summary.totalIncome),
                  subtitle:
                      '${summary.totalTransactionCount} Total Ledger Entries',
                  icon: Icons.arrow_downward_rounded,
                  iconColor: MonetraColors.incomeGreen,
                ),
                const SizedBox(height: 12),
                StatCard(
                  title: 'Total Expenses',
                  value: CurrencyFormatter.format(summary.totalExpenses),
                  subtitle:
                      '${CurrencyFormatter.format(summary.avgDailySpending)} Daily Average',
                  icon: Icons.arrow_upward_rounded,
                  iconColor: MonetraColors.expenseRed,
                ),
                const SizedBox(height: 12),
                StatCard(
                  title: 'Net Savings Rate',
                  value: '${summary.savingsRate.toStringAsFixed(1)}%',
                  subtitle:
                      'Net Savings: ${CurrencyFormatter.format(summary.netSavings)}',
                  icon: Icons.savings_rounded,
                  iconColor: theme.colorScheme.primary,
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Total Income',
                    value: CurrencyFormatter.format(summary.totalIncome),
                    subtitle:
                        '${summary.totalTransactionCount} Total Ledger Entries',
                    icon: Icons.arrow_downward_rounded,
                    iconColor: MonetraColors.incomeGreen,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    title: 'Total Expenses',
                    value: CurrencyFormatter.format(summary.totalExpenses),
                    subtitle:
                        '${CurrencyFormatter.format(summary.avgDailySpending)} Daily Average',
                    icon: Icons.arrow_upward_rounded,
                    iconColor: MonetraColors.expenseRed,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    title: 'Net Savings Rate',
                    value: '${summary.savingsRate.toStringAsFixed(1)}%',
                    subtitle:
                        'Net Savings: ${CurrencyFormatter.format(summary.netSavings)}',
                    icon: Icons.savings_rounded,
                    iconColor: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 24),
          // Category Breakdown Card
          MonetraCard(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Spending by Category',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 16),
                if (categoryBreakdown.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                        child: Text(
                            'No spending category data available for selected period.')),
                  )
                else
                  Column(
                    children: categoryBreakdown.map((share) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(share.categoryName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                                Text(
                                  '${CurrencyFormatter.format(share.totalAmount)} (${share.percentage.toStringAsFixed(1)}%)',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: share.percentage / 100.0,
                                minHeight: 8,
                                backgroundColor:
                                    theme.dividerColor.withValues(alpha: 0.3),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.colorScheme.primary),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
