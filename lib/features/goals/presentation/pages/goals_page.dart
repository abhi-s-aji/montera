import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/entities/goal.dart';
import '../../../../core/providers/goal_providers.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/theme/monetra_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/monetra_card.dart';
import '../widgets/goal_contribution_dialog.dart';
import '../widgets/goal_editor_dialog.dart';

class GoalsPage extends ConsumerWidget {
  const GoalsPage({super.key});

  void _showContextOptions(BuildContext context, WidgetRef ref, Goal goal) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.add_circle_outline,
                color: MonetraColors.incomeGreen),
            title: const Text('Add Savings Contribution'),
            onTap: () {
              Navigator.of(ctx).pop();
              GoalContributionDialog.show(context,
                  goal: goal, isWithdrawal: false);
            },
          ),
          ListTile(
            leading: const Icon(Icons.remove_circle_outline,
                color: MonetraColors.expenseRed),
            title: const Text('Withdraw Savings'),
            onTap: () {
              Navigator.of(ctx).pop();
              GoalContributionDialog.show(context,
                  goal: goal, isWithdrawal: true);
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Edit Goal Details'),
            onTap: () {
              Navigator.of(ctx).pop();
              GoalEditorDialog.show(context, goal: goal);
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy_outlined),
            title: const Text('Duplicate Goal'),
            onTap: () async {
              Navigator.of(ctx).pop();
              await ref.read(goalRepositoryProvider).duplicateGoal(goal.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Goal duplicated')),
                );
              }
            },
          ),
          ListTile(
            leading: Icon(goal.isArchived
                ? Icons.unarchive_outlined
                : Icons.archive_outlined),
            title: Text(goal.isArchived ? 'Restore Goal' : 'Archive Goal'),
            onTap: () async {
              Navigator.of(ctx).pop();
              await ref
                  .read(goalRepositoryProvider)
                  .archiveGoal(goal.id, !goal.isArchived);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          goal.isArchived ? 'Goal restored' : 'Goal archived')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline,
                color: MonetraColors.expenseRed),
            title: const Text('Delete Goal',
                style: TextStyle(color: MonetraColors.expenseRed)),
            onTap: () async {
              Navigator.of(ctx).pop();
              await ref.read(goalRepositoryProvider).deleteGoal(goal.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Goal deleted')),
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
    final goalProgressList = ref.watch(goalProgressListProvider);
    final searchQuery = ref.watch(goalSearchQueryProvider);
    final showArchived = ref.watch(goalShowArchivedProvider);

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
                    'Goals & Savings Targets',
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
                  onPressed: () => GoalEditorDialog.show(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Create'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Milestone tracking & reserves',
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
                      'Goals & Savings Targets',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Milestone tracking, debt reduction, and liquid emergency reserves',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textTheme.bodyMedium?.color
                            ?.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => GoalEditorDialog.show(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Create Goal'),
                ),
              ],
            ),
          const SizedBox(height: 20),
          // Search & Filter Toolbar
          if (isMobile) ...[
            TextField(
              onChanged: (val) =>
                  ref.read(goalSearchQueryProvider.notifier).state = val,
              decoration: InputDecoration(
                hintText: 'Search goals...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => ref
                            .read(goalSearchQueryProvider.notifier)
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
                    ref.read(goalShowArchivedProvider.notifier).state = val,
              ),
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) =>
                        ref.read(goalSearchQueryProvider.notifier).state = val,
                    decoration: InputDecoration(
                      hintText: 'Search goals by title...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () => ref
                                  .read(goalSearchQueryProvider.notifier)
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
                      ref.read(goalShowArchivedProvider.notifier).state = val,
                ),
              ],
            ),
          const SizedBox(height: 24),
          Expanded(
            child: goalProgressList.isEmpty
                ? Center(
                    child: Text(
                      'No financial goals created yet.',
                      style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.6)),
                    ),
                  )
                : ListView.separated(
                    itemCount: goalProgressList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = goalProgressList[index];
                      final g = item.goal;
                      final isCompleted = g.currentAmount >= g.targetAmount;

                      return InkWell(
                        onLongPress: () => _showContextOptions(context, ref, g),
                        onTap: () => GoalEditorDialog.show(context, goal: g),
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
                                        Wrap(
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          spacing: 8,
                                          runSpacing: 4,
                                          children: [
                                            Text(
                                              g.title,
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            if (isCompleted)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: MonetraColors.incomeGreen
                                                      .withValues(alpha: 0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: const Text('COMPLETED',
                                                    style: TextStyle(
                                                        fontSize: 9,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: MonetraColors
                                                            .incomeGreen)),
                                              ),
                                          ],
                                        ),
                                        Text(g.type.name.toUpperCase(),
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: theme
                                                    .textTheme.bodyMedium?.color
                                                    ?.withValues(alpha: 0.6))),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${CurrencyFormatter.format(g.currentAmount)} / ${CurrencyFormatter.format(g.targetAmount)}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: isCompleted
                                              ? MonetraColors.incomeGreen
                                              : theme
                                                  .textTheme.bodyMedium?.color,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.more_vert_rounded,
                                            size: 18),
                                        onPressed: () => _showContextOptions(
                                            context, ref, g),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: item.progressPercentage,
                                  minHeight: 10,
                                  backgroundColor:
                                      theme.dividerColor.withValues(alpha: 0.3),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isCompleted
                                        ? MonetraColors.incomeGreen
                                        : theme.colorScheme.primary,
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
                                    isCompleted
                                        ? 'Goal Target Achieved!'
                                        : '${CurrencyFormatter.format(item.remainingAmount)} remaining target',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isCompleted
                                          ? MonetraColors.incomeGreen
                                          : theme.textTheme.bodyMedium?.color
                                              ?.withValues(alpha: 0.8),
                                    ),
                                  ),
                                  Text(
                                    isCompleted
                                        ? '100%'
                                        : '${CurrencyFormatter.format(item.requiredDailyContribution)} / day (${item.remainingDays} days remaining)',
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
