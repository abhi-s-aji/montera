import 'package:monetra/core/domain/entities/account.dart';
import 'package:monetra/core/domain/entities/budget.dart';
import 'package:monetra/core/domain/entities/category.dart';
import 'package:monetra/core/domain/entities/goal.dart';
import 'package:monetra/core/domain/entities/transaction.dart';
import 'package:monetra/features/search/domain/entities/search_result.dart';

class UniversalSearchIndex {
  static List<SearchResultItem> buildIndex({
    required List<TransactionEntity> transactions,
    required List<Account> accounts,
    required List<Category> categories,
    required List<Budget> budgets,
    required List<Goal> goals,
  }) {
    final List<SearchResultItem> items = [];

    for (final tx in transactions) {
      items.add(SearchResultItem(
        id: tx.id,
        title: tx.description,
        subtitle:
            'Transaction • ${tx.amount < 0 ? "-" : "+"}\$${tx.amount.abs().toStringAsFixed(2)} • ${tx.date.toIso8601String().split("T").first}',
        type: SearchResultType.transaction,
        targetRoute: '/transactions',
        icon: 'receipt',
      ));
    }

    for (final acc in accounts) {
      items.add(SearchResultItem(
        id: acc.id,
        title: acc.name,
        subtitle: 'Account • Balance: \$${acc.balance.toStringAsFixed(2)}',
        type: SearchResultType.account,
        targetRoute: '/accounts',
        icon: 'account_balance',
      ));
    }

    for (final cat in categories) {
      items.add(SearchResultItem(
        id: cat.id,
        title: cat.name,
        subtitle: 'Category • ${cat.type.name.toUpperCase()}',
        type: SearchResultType.category,
        targetRoute: '/categories',
        icon: 'category',
      ));
    }

    for (final b in budgets) {
      items.add(SearchResultItem(
        id: b.id,
        title: b.name,
        subtitle: 'Budget Limit • \$${b.amount.toStringAsFixed(2)}',
        type: SearchResultType.budget,
        targetRoute: '/budgets',
        icon: 'pie_chart',
      ));
    }

    for (final g in goals) {
      items.add(SearchResultItem(
        id: g.id,
        title: g.title,
        subtitle:
            'Savings Goal • Target: \$${g.targetAmount.toStringAsFixed(2)}',
        type: SearchResultType.goal,
        targetRoute: '/goals',
        icon: 'flag',
      ));
    }

    return items;
  }
}

class FuzzySearchEngine {
  static List<SearchResultItem> search({
    required String query,
    required List<SearchResultItem> indexItems,
    required List<CommandItem> commands,
  }) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return [];

    final List<SearchResultItem> results = [];

    // Search Commands
    for (final cmd in commands) {
      if (cmd.label.toLowerCase().contains(cleanQuery) ||
          cmd.description.toLowerCase().contains(cleanQuery)) {
        results.add(SearchResultItem(
          id: cmd.id,
          title: cmd.label,
          subtitle: 'Command • ${cmd.description}',
          type: SearchResultType.command,
          targetRoute: cmd.targetRoute,
          icon: 'terminal',
        ));
      }
    }

    // Search Entities Index
    for (final item in indexItems) {
      if (item.title.toLowerCase().contains(cleanQuery) ||
          item.subtitle.toLowerCase().contains(cleanQuery)) {
        results.add(item);
      }
    }

    return results;
  }
}
