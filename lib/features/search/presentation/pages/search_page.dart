import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:monetra/core/widgets/monetra_card.dart';
import 'package:monetra/features/search/presentation/providers/search_providers.dart';
import 'package:monetra/features/search/presentation/widgets/command_palette_overlay.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _queryController = TextEditingController();

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _openCommandPalette(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const CommandPaletteOverlay(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final results = ref.watch(searchResultsListProvider);
    final recents = ref.watch(recentSearchHistoryProvider);

    final isMobile = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) ...[
            Text(
              'Global Search & Command Palette',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Universal offline search',
              style: TextStyle(
                fontSize: 13,
                color: theme.textTheme.bodyMedium?.color
                    ?.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _openCommandPalette(context),
              icon: const Icon(Icons.terminal_rounded, size: 18),
              label: const Text('Open Palette (Ctrl+K)'),
            ),
          ] else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Global Search & Command Palette',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Universal offline search across Transactions, Accounts, Categories, Budgets, and Commands',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textTheme.bodyMedium?.color
                            ?.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _openCommandPalette(context),
                  icon: const Icon(Icons.terminal_rounded, size: 18),
                  label: const Text('Open Palette (Ctrl+K)'),
                ),
              ],
            ),
          const SizedBox(height: 24),

          // Search Bar Input Card
          MonetraCard(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _queryController,
                  decoration: InputDecoration(
                    hintText:
                        'Search transactions, accounts, categories, budgets, or commands...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _queryController.clear();
                        ref.read(globalSearchQueryProvider.notifier).state = '';
                      },
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (val) {
                    ref.read(globalSearchQueryProvider.notifier).state = val;
                  },
                ),
                if (recents.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: recents
                        .map(
                            (q) => ActionChip(label: Text(q), onPressed: () {}))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Search Results Section
          Text('Search Results (${results.length})',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color)),
          const SizedBox(height: 12),

          results.isEmpty
              ? MonetraCard(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 48,
                            color: Colors.grey.withValues(alpha: 0.5)),
                        const SizedBox(height: 12),
                        Text('No matching entity or command records found.',
                            style: TextStyle(
                                color: theme.textTheme.bodyMedium?.color
                                    ?.withValues(alpha: 0.6))),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: results.length,
                  itemBuilder: (ctx, idx) {
                    final res = results[idx];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: MonetraCard(
                        padding: const EdgeInsets.all(12.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primary
                                .withValues(alpha: 0.1),
                            child: Icon(
                              res.type.name == 'transaction'
                                  ? Icons.receipt_rounded
                                  : res.type.name == 'command'
                                      ? Icons.terminal_rounded
                                      : Icons.account_balance_wallet_rounded,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          title: Text(res.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(res.subtitle),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded,
                              size: 14),
                          onTap: () => context.go(res.targetRoute),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
