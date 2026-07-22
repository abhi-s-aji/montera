import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/account.dart';
import 'repository_providers.dart';

// State providers for Search & Filters
final accountSearchQueryProvider = StateProvider<String>((ref) => '');
final accountTypeFilterProvider = StateProvider<AccountType?>((ref) => null);
final accountShowArchivedProvider = StateProvider<bool>((ref) => false);
final accountSortByProvider =
    StateProvider<String>((ref) => 'name'); // name, balance, type

// Accounts Watch Stream Provider
final accountsStreamProvider = StreamProvider<List<Account>>((ref) {
  final repo = ref.watch(accountRepositoryProvider);
  final showArchived = ref.watch(accountShowArchivedProvider);
  return repo.watchAllAccounts(includeArchived: showArchived);
});

// Filtered & Sorted Accounts List Provider
final filteredAccountsProvider = Provider<List<Account>>((ref) {
  final accountsAsync = ref.watch(accountsStreamProvider);
  final query = ref.watch(accountSearchQueryProvider).trim().toLowerCase();
  final typeFilter = ref.watch(accountTypeFilterProvider);
  final sortBy = ref.watch(accountSortByProvider);

  return accountsAsync.when(
    data: (accounts) {
      var list = accounts.where((a) {
        final matchesQuery = query.isEmpty ||
            a.name.toLowerCase().contains(query) ||
            (a.institutionName?.toLowerCase().contains(query) ?? false) ||
            (a.accountNumberMasked?.toLowerCase().contains(query) ?? false);
        final matchesType = typeFilter == null || a.type == typeFilter;
        return matchesQuery && matchesType;
      }).toList();

      if (sortBy == 'name') {
        list.sort((a, b) => a.name.compareTo(b.name));
      } else if (sortBy == 'balance') {
        list.sort((a, b) => b.balance.compareTo(a.balance));
      } else if (sortBy == 'type') {
        list.sort((a, b) => a.type.name.compareTo(b.type.name));
      }

      return list;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Total Net Worth Provider
final totalNetWorthProvider = Provider<double>((ref) {
  final accountsAsync = ref.watch(accountsStreamProvider);
  return accountsAsync.when(
    data: (accounts) {
      double total = 0;
      for (final acc in accounts) {
        if (!acc.isArchived) {
          total += acc.balance;
        }
      }
      return total;
    },
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});
