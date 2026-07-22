import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monetra/core/providers/account_providers.dart';
import 'package:monetra/core/providers/budget_providers.dart';
import 'package:monetra/core/providers/category_providers.dart';
import 'package:monetra/core/providers/goal_providers.dart';
import 'package:monetra/core/providers/transaction_providers.dart';
import 'package:monetra/features/search/domain/entities/search_result.dart';
import 'package:monetra/features/search/services/search_index_engine.dart';

final globalSearchQueryProvider = StateProvider<String>((ref) => '');

final isCommandPaletteOpenProvider = StateProvider<bool>((ref) => false);

final availableCommandsProvider = Provider<List<CommandItem>>((ref) => const [
      CommandItem(
          id: 'cmd-1',
          label: 'Create New Transaction',
          description: 'Open transaction creation dialog',
          targetRoute: '/transactions'),
      CommandItem(
          id: 'cmd-2',
          label: 'Create New Account',
          description: 'Open account creation wizard',
          targetRoute: '/accounts'),
      CommandItem(
          id: 'cmd-3',
          label: 'Create New Budget',
          description: 'Setup spending category budget limit',
          targetRoute: '/budgets'),
      CommandItem(
          id: 'cmd-4',
          label: 'Create Savings Goal',
          description: 'Setup target savings objective',
          targetRoute: '/goals'),
      CommandItem(
          id: 'cmd-5',
          label: 'Open Analytics Studio',
          description: 'Inspect financial cash flow charts',
          targetRoute: '/analytics'),
      CommandItem(
          id: 'cmd-6',
          label: 'Generate Reports',
          description: 'Export CSV, JSON, or GFM report file',
          targetRoute: '/reports'),
      CommandItem(
          id: 'cmd-7',
          label: 'Open Backup Studio',
          description: 'Create containerized .monetra archive',
          targetRoute: '/backup'),
      CommandItem(
          id: 'cmd-8',
          label: 'Open Import Studio',
          description: 'Ingest external CSV or JSON transactions',
          targetRoute: '/import'),
      CommandItem(
          id: 'cmd-9',
          label: 'Open Security Studio',
          description: 'Configure PIN and Privacy Mode settings',
          targetRoute: '/security'),
      CommandItem(
          id: 'cmd-10',
          label: 'Open Automation Studio',
          description: 'Manage recurring schedules and rules',
          targetRoute: '/automation'),
    ]);

final universalIndexProvider = Provider<List<SearchResultItem>>((ref) {
  final transactions = ref.watch(transactionsStreamProvider).value ?? [];
  final accounts = ref.watch(accountsStreamProvider).value ?? [];
  final categories = ref.watch(categoriesStreamProvider).value ?? [];
  final budgets = ref.watch(budgetsStreamProvider).value ?? [];
  final goals = ref.watch(goalsStreamProvider).value ?? [];

  return UniversalSearchIndex.buildIndex(
    transactions: transactions,
    accounts: accounts,
    categories: categories,
    budgets: budgets,
    goals: goals,
  );
});

final searchResultsListProvider = Provider<List<SearchResultItem>>((ref) {
  final query = ref.watch(globalSearchQueryProvider);
  final indexItems = ref.watch(universalIndexProvider);
  final commands = ref.watch(availableCommandsProvider);

  return FuzzySearchEngine.search(
    query: query,
    indexItems: indexItems,
    commands: commands,
  );
});

final recentSearchHistoryProvider = StateProvider<List<String>>((ref) => []);
