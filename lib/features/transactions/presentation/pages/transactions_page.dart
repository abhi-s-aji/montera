import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/category_providers.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/providers/transaction_providers.dart';
import '../../../../core/theme/monetra_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/monetra_card.dart';
import '../widgets/transaction_editor_dialog.dart';

class TransactionsPage extends ConsumerStatefulWidget {
  const TransactionsPage({super.key});

  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage> {
  final Set<String> _selectedTxIds = {};
  bool _isSelectionMode = false;

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedTxIds.contains(id)) {
        _selectedTxIds.remove(id);
        if (_selectedTxIds.isEmpty) _isSelectionMode = false;
      } else {
        _selectedTxIds.add(id);
        _isSelectionMode = true;
      }
    });
  }

  Future<void> _deleteSelected() async {
    final repo = ref.read(transactionRepositoryProvider);
    await repo.bulkDeleteTransactions(_selectedTxIds.toList());
    setState(() {
      _selectedTxIds.clear();
      _isSelectionMode = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected transactions deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transactions = ref.watch(filteredTransactionsProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    final searchQuery = ref.watch(transactionSearchQueryProvider);
    final categoryFilter = ref.watch(transactionCategoryFilterProvider);

    final isMobile = MediaQuery.of(context).size.width < 600;

    Widget buildDropdownFilter(List<dynamic> categories) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            isExpanded: isMobile,
            value: categoryFilter,
            hint: const Text('All Categories'),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('All Categories'),
              ),
              ...categories.map((c) => DropdownMenuItem<String?>(
                    value: c.id,
                    child: Text(c.name),
                  )),
            ],
            onChanged: (val) => ref
                .read(transactionCategoryFilterProvider.notifier)
                .state = val,
          ),
        ),
      );
    }

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
                    'Transaction Ledger',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    if (_isSelectionMode)
                      IconButton.filledTonal(
                        icon: const Icon(Icons.delete_outline,
                            color: MonetraColors.expenseRed),
                        onPressed: _deleteSelected,
                      ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => TransactionEditorDialog.show(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Entry'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _isSelectionMode
                  ? '${_selectedTxIds.length} Selected'
                  : 'Complete ledger history and search',
              style: TextStyle(
                fontSize: 13,
                color: _isSelectionMode
                    ? theme.colorScheme.primary
                    : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                fontWeight:
                    _isSelectionMode ? FontWeight.bold : FontWeight.normal,
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
                      'Transaction Ledger',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isSelectionMode
                          ? '${_selectedTxIds.length} Selected'
                          : 'Complete ledger history and instant multi-field search',
                      style: TextStyle(
                        fontSize: 14,
                        color: _isSelectionMode
                            ? theme.colorScheme.primary
                            : theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.6),
                        fontWeight: _isSelectionMode
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (_isSelectionMode)
                      IconButton.filledTonal(
                        icon: const Icon(Icons.delete_outline,
                            color: MonetraColors.expenseRed),
                        onPressed: _deleteSelected,
                      ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => TransactionEditorDialog.show(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Entry'),
                    ),
                  ],
                ),
              ],
            ),
          const SizedBox(height: 20),
          // Search & Filter Toolbar
          if (isMobile) ...[
            TextField(
              onChanged: (val) =>
                  ref.read(transactionSearchQueryProvider.notifier).state = val,
              decoration: InputDecoration(
                hintText: 'Search description, notes...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => ref
                            .read(transactionSearchQueryProvider.notifier)
                            .state = '',
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            categoriesAsync.when(
              data: (categories) => buildDropdownFilter(categories),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) => ref
                        .read(transactionSearchQueryProvider.notifier)
                        .state = val,
                    decoration: InputDecoration(
                      hintText: 'Search description, notes, or tags...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () => ref
                                  .read(transactionSearchQueryProvider.notifier)
                                  .state = '',
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                categoriesAsync.when(
                  data: (categories) => buildDropdownFilter(categories),
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
              ],
            ),
          const SizedBox(height: 20),
          // Ledger List
          Expanded(
            child: MonetraCard(
              padding: const EdgeInsets.all(12),
              child: transactions.isEmpty
                  ? Center(
                      child: Text(
                        'No matching transactions found.',
                        style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.6)),
                      ),
                    )
                  : ListView.separated(
                      itemCount: transactions.length,
                      separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: theme.dividerColor.withValues(alpha: 0.3)),
                      itemBuilder: (context, index) {
                        final tx = transactions[index];
                        final isExpense = tx.amount < 0;
                        final isSelected = _selectedTxIds.contains(tx.id);

                        return Dismissible(
                          key: Key(tx.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color:
                                MonetraColors.expenseRed.withValues(alpha: 0.8),
                            child: const Icon(Icons.delete_outline_rounded,
                                color: Colors.white),
                          ),
                          onDismissed: (_) async {
                            await ref
                                .read(transactionRepositoryProvider)
                                .deleteTransaction(tx.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Deleted "${tx.description}"'),
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    onPressed: () async {
                                      await ref
                                          .read(transactionRepositoryProvider)
                                          .createTransaction(tx);
                                    },
                                  ),
                                ),
                              );
                            }
                          },
                          child: ListTile(
                            selected: isSelected,
                            selectedTileColor: theme.colorScheme.primary
                                .withValues(alpha: 0.08),
                            onLongPress: () => _toggleSelection(tx.id),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
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
                            title: Text(
                              tx.description,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            subtitle: Wrap(
                              spacing: 8,
                              children: [
                                Text(
                                  '${tx.date.day}/${tx.date.month}/${tx.date.year}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: theme.textTheme.bodyMedium?.color
                                          ?.withValues(alpha: 0.6)),
                                ),
                                if (tx.tags.isNotEmpty)
                                  ...tx.tags.map((tag) => Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '#$tag',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: theme.colorScheme.primary),
                                        ),
                                      )),
                              ],
                            ),
                            trailing: Text(
                              CurrencyFormatter.format(tx.amount,
                                  showSign: true),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isExpense
                                    ? theme.textTheme.bodyLarge?.color
                                    : MonetraColors.incomeGreen,
                              ),
                            ),
                            onTap: () {
                              if (_isSelectionMode) {
                                _toggleSelection(tx.id);
                              } else {
                                TransactionEditorDialog.show(context,
                                    transaction: tx);
                              }
                            },
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
