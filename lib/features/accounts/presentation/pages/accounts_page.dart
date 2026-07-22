import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/entities/account.dart';
import '../../../../core/providers/account_providers.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/theme/monetra_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/icon_helper.dart';
import '../../../../core/widgets/monetra_card.dart';
import '../widgets/account_editor_dialog.dart';

class AccountsPage extends ConsumerWidget {
  const AccountsPage({super.key});

  void _showContextOptions(
      BuildContext context, WidgetRef ref, Account account) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Edit Account'),
            onTap: () {
              Navigator.of(ctx).pop();
              AccountEditorDialog.show(context, account: account);
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy_outlined),
            title: const Text('Duplicate Account'),
            onTap: () async {
              Navigator.of(ctx).pop();
              await ref
                  .read(accountRepositoryProvider)
                  .duplicateAccount(account.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Account duplicated')),
                );
              }
            },
          ),
          ListTile(
            leading: Icon(account.isArchived
                ? Icons.unarchive_outlined
                : Icons.archive_outlined),
            title: Text(account.isArchived
                ? 'Restore from Archive'
                : 'Archive Account'),
            onTap: () async {
              Navigator.of(ctx).pop();
              await ref
                  .read(accountRepositoryProvider)
                  .archiveAccount(account.id, !account.isArchived);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(account.isArchived
                          ? 'Account restored'
                          : 'Account archived')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline,
                color: MonetraColors.expenseRed),
            title: const Text('Delete Account',
                style: TextStyle(color: MonetraColors.expenseRed)),
            onTap: () async {
              Navigator.of(ctx).pop();
              await ref
                  .read(accountRepositoryProvider)
                  .deleteAccount(account.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Account deleted')),
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
    final accounts = ref.watch(filteredAccountsProvider);
    final totalNetWorth = ref.watch(totalNetWorthProvider);
    final searchQuery = ref.watch(accountSearchQueryProvider);
    final showArchived = ref.watch(accountShowArchivedProvider);

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Financial Accounts',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Total Net Worth: ${CurrencyFormatter.format(totalNetWorth)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => AccountEditorDialog.show(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
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
                      'Financial Accounts',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Net Worth: ${CurrencyFormatter.format(totalNetWorth)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => AccountEditorDialog.show(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Account'),
                ),
              ],
            ),
          const SizedBox(height: 20),
          // Search & Filters Header Bar
          if (isMobile) ...[
            TextField(
              onChanged: (val) =>
                  ref.read(accountSearchQueryProvider.notifier).state = val,
              decoration: InputDecoration(
                hintText: 'Search accounts...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => ref
                            .read(accountSearchQueryProvider.notifier)
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
                    ref.read(accountShowArchivedProvider.notifier).state = val,
              ),
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) => ref
                        .read(accountSearchQueryProvider.notifier)
                        .state = val,
                    decoration: InputDecoration(
                      hintText: 'Search accounts by name or institution...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () => ref
                                  .read(accountSearchQueryProvider.notifier)
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
                  onSelected: (val) => ref
                      .read(accountShowArchivedProvider.notifier)
                      .state = val,
                ),
              ],
            ),
          const SizedBox(height: 24),
          Expanded(
            child: accounts.isEmpty
                ? Center(
                    child: Text(
                      'No matching accounts found.',
                      style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.6)),
                    ),
                  )
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isMobile ? 1 : 2,
                      childAspectRatio: isMobile ? 2.5 : 2.2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: accounts.length,
                    itemBuilder: (context, index) {
                      final acc = accounts[index];
                      final accentColor =
                          MonetraColors.hexToColor(acc.colorHex);

                      return InkWell(
                        onLongPress: () =>
                            _showContextOptions(context, ref, acc),
                        onTap: () =>
                            AccountEditorDialog.show(context, account: acc),
                        borderRadius: BorderRadius.circular(16),
                        child: MonetraCard(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color:
                                          accentColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      IconHelper.getIconData(acc.icon),
                                      color: accentColor,
                                      size: 22,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      if (acc.isArchived)
                                        Container(
                                          margin:
                                              const EdgeInsets.only(right: 6),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.grey
                                                .withValues(alpha: 0.2),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Text('ARCHIVED',
                                              style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.more_vert_rounded,
                                            size: 18),
                                        onPressed: () => _showContextOptions(
                                            context, ref, acc),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    acc.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (acc.institutionName != null)
                                    Text(
                                      acc.institutionName!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: theme.textTheme.bodyMedium?.color
                                            ?.withValues(alpha: 0.6),
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    CurrencyFormatter.format(acc.balance,
                                        currency: acc.currency),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: acc.balance < 0
                                          ? MonetraColors.expenseRed
                                          : theme.textTheme.bodyLarge?.color,
                                    ),
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
