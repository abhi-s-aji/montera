import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/entities/budget.dart';
import '../../../../core/providers/budget_providers.dart';
import '../../../../core/providers/category_providers.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/theme/monetra_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/monetra_card.dart';
import '../widgets/budget_editor_dialog.dart';

class BudgetsPage extends ConsumerWidget {
  const BudgetsPage({super.key});

  void _showContextOptions(BuildContext context, WidgetRef ref, Budget budget) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Edit Budget'),
            onTap: () {
              Navigator.of(ctx).pop();
              BudgetEditorDialog.show(context, budget: budget);
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy_outlined),
            title: const Text('Duplicate Budget'),
            onTap: () async {
              Navigator.of(ctx).pop();
              await ref
                  .read(budgetRepositoryProvider)
                  .duplicateBudget(budget.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Budget duplicated')),
                );
              }
            },
          ),
          ListTile(
            leading: Icon(budget.isArchived
                ? Icons.unarchive_outlined
                : Icons.archive_outlined),
            title:
                Text(budget.isArchived ? 'Restore Budget' : 'Archive Budget'),
            onTap: () async {
              Navigator.of(ctx).pop();
              await ref
                  .read(budgetRepositoryProvider)
                  .archiveBudget(budget.id, !budget.isArchived);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(budget.isArchived
                          ? 'Budget restored'
                          : 'Budget archived')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline,
                color: MonetraColors.expenseRed),
            title: const Text('Delete Budget',
                style: TextStyle(color: MonetraColors.expenseRed)),
            onTap: () async {
              Navigator.of(ctx).pop();
              await ref.read(budgetRepositoryProvider).deleteBudget(budget.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Budget deleted')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final budgetProgressList = ref.watch(budgetProgressListProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final searchQuery = ref.watch(budgetSearchQueryProvider);
    final showArchived = ref.watch(budgetShowArchivedProvider);

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Budget Limits & Velocity',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => BudgetEditorDialog.show(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Set Budget'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Category spending caps and pace',
              style: TextStyle(
                fontSize: 13,
                color: theme.textTheme.bodyMedium?.color
                    ?.withValues(alpha: 0.6),
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
                      'Budget Limits & Velocity',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Category spending caps and real-time pace indicators',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textTheme.bodyMedium?.color
                            ?.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => BudgetEditorDialog.show(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Set Budget'),
                ),
              ],
            ),
          const SizedBox(height: 20),
          // Search & Filter Bar
          if (isMobile) ...[
            TextField(
              onChanged: (val) =>
                  ref.read(budgetSearchQueryProvider.notifier).state = val,
              decoration: InputDecoration(
                hintText: 'Search budgets...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => ref
                            .read(budgetSearchQueryProvider.notifier)
                            .state = '',
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: FilterChip(
                label: const Text('Show Archived'),
                selected: showArchived,
                onSelected: (val) =>
                    ref.read(budgetShowArchivedProvider.notifier).state = val,
              ),
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) =>
                        ref.read(budgetSearchQueryProvider.notifier).state = val,
                    decoration: InputDecoration(
                      hintText: 'Search budgets by name...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () => ref
                                  .read(budgetSearchQueryProvider.notifier)
                                  .state = '',
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                FilterChip(
                  label: const Text('Show Archived'),
                  selected: showArchived,
                  onSelected: (val) =>
                      ref.read(budgetShowArchivedProvider.notifier).state = val,
                ),
              ],
            ),
          const SizedBox(height: 24),
          Expanded(
            child: budgetProgressList.isEmpty
                ? Center(
                    child: Text(
                      'No active budget limits configured.',
                      style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.6)),
                    ),
                  )
                : ListView.separated(
                    itemCount: budgetProgressList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = budgetProgressList[index];
                      final b = item.budget;

                      final categoryName = categoriesAsync.when(
                        data: (cats) {
                          try {
                            return cats
                                .firstWhere((c) => c.id == b.categoryId)
                                .name;
                          } catch (_) {
                            return 'Uncategorized';
                          }
                        },
                        loading: () => 'Loading...',
                        error: (_, __) => 'Category',
                      );

                      return InkWell(
                        onLongPress: () => _showContextOptions(context, ref, b),
                        onTap: () =>
                            BudgetEditorDialog.show(context, budget: b),
                        borderRadius: BorderRadius.circular(16),
                        child: MonetraCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          b.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          categoryName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: theme
                                                  .textTheme.bodyMedium?.color
                                                  ?.withValues(alpha: 0.6)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${CurrencyFormatter.format(item.spentAmount)} / ${CurrencyFormatter.format(b.amount)}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: item.isOverBudget
                                              ? MonetraColors.expenseRed
                                              : theme
                                                  .textTheme.bodyMedium?.color,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.more_vert_rounded,
                                            size: 18),
                                        onPressed: () => _showContextOptions(
                                            context, ref, b),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: item.progress,
                                  minHeight: 10,
                                  backgroundColor:
                                      theme.dividerColor.withValues(alpha: 0.3),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    item.isOverBudget
                                        ? MonetraColors.expenseRed
                                        : (item.progress > b.warningThreshold
                                            ? MonetraColors.warningAmber
                                            : theme.colorScheme.primary),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  Text(
                                    item.isOverBudget
                                        ? 'Over limit by ${CurrencyFormatter.format(item.spentAmount - b.amount)}'
                                        : '${CurrencyFormatter.format(item.remainingAmount)} remaining',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: item.isOverBudget
                                          ? MonetraColors.expenseRed
                                          : theme.textTheme.bodyMedium?.color
                                              ?.withValues(alpha: 0.8),
                                    ),
                                  ),
                                  Text(
                                    item.isOverBudget
                                        ? '0 / day pace'
                                        : '${CurrencyFormatter.format(item.dailyAllowance)} / day pace (${item.remainingDays} days left)',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: theme.textTheme.bodyMedium?.color
                                            ?.withValues(alpha: 0.6)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
