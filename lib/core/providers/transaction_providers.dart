import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/transaction.dart';
import 'repository_providers.dart';

// State providers for Search & Advanced Filters
final transactionSearchQueryProvider = StateProvider<String>((ref) => '');
final transactionCategoryFilterProvider = StateProvider<String?>((ref) => null);
final transactionAccountFilterProvider = StateProvider<String?>((ref) => null);
final transactionTypeFilterProvider =
    StateProvider<TransactionType?>((ref) => null);
final transactionStatusFilterProvider =
    StateProvider<TransactionStatus?>((ref) => null);

// Transactions Watch Stream Provider
final transactionsStreamProvider =
    StreamProvider<List<TransactionEntity>>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.watchAllTransactions();
});

// Filtered Transactions List Provider
final filteredTransactionsProvider = Provider<List<TransactionEntity>>((ref) {
  final transactionsAsync = ref.watch(transactionsStreamProvider);
  final query = ref.watch(transactionSearchQueryProvider).trim().toLowerCase();
  final categoryFilter = ref.watch(transactionCategoryFilterProvider);
  final accountFilter = ref.watch(transactionAccountFilterProvider);
  final typeFilter = ref.watch(transactionTypeFilterProvider);
  final statusFilter = ref.watch(transactionStatusFilterProvider);

  return transactionsAsync.when(
    data: (transactions) {
      return transactions.where((t) {
        final matchesQuery = query.isEmpty ||
            t.description.toLowerCase().contains(query) ||
            (t.notes?.toLowerCase().contains(query) ?? false) ||
            t.tags.any((tag) => tag.toLowerCase().contains(query));
        final matchesCategory =
            categoryFilter == null || t.categoryId == categoryFilter;
        final matchesAccount = accountFilter == null ||
            t.accountId == accountFilter ||
            t.destinationAccountId == accountFilter;
        final matchesType = typeFilter == null || t.type == typeFilter;
        final matchesStatus = statusFilter == null || t.status == statusFilter;

        return matchesQuery &&
            matchesCategory &&
            matchesAccount &&
            matchesType &&
            matchesStatus;
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Month-to-Date Income Calculation Provider
final monthToDateIncomeProvider = Provider<double>((ref) {
  final transactionsAsync = ref.watch(transactionsStreamProvider);
  final now = DateTime.now();

  return transactionsAsync.when(
    data: (transactions) {
      double total = 0;
      for (final t in transactions) {
        if (t.amount > 0 &&
            t.date.month == now.month &&
            t.date.year == now.year &&
            t.type != TransactionType.transfer) {
          total += t.amount;
        }
      }
      return total;
    },
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

// Month-to-Date Expense Calculation Provider
final monthToDateExpenseProvider = Provider<double>((ref) {
  final transactionsAsync = ref.watch(transactionsStreamProvider);
  final now = DateTime.now();

  return transactionsAsync.when(
    data: (transactions) {
      double total = 0;
      for (final t in transactions) {
        if (t.amount < 0 &&
            t.date.month == now.month &&
            t.date.year == now.year &&
            t.type != TransactionType.transfer) {
          total += t.amount.abs();
        }
      }
      return total;
    },
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});
