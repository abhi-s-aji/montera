import 'package:flutter_test/flutter_test.dart';

import 'package:monetra/core/domain/entities/account.dart';
import 'package:monetra/core/domain/entities/category.dart';
import 'package:monetra/features/search/domain/entities/search_result.dart';
import 'package:monetra/features/search/services/search_index_engine.dart';

void main() {
  group('Monetra Global Search & Command Palette Unit Tests', () {
    test('UniversalSearchIndex builds indexing items from domain entities', () {
      final account = Account(
        id: 'acc-1',
        name: 'Checking Account',
        type: AccountType.checking,
        openingBalance: 1500.0,
        balance: 1500.0,
        icon: 'account_balance',
        colorHex: '#2196F3',
        currency: 'USD',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final category = Category(
        id: 'cat-1',
        name: 'Groceries',
        icon: 'shopping_cart',
        colorHex: '#4CAF50',
        type: CategoryType.expense,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final index = UniversalSearchIndex.buildIndex(
        transactions: const [],
        accounts: [account],
        categories: [category],
        budgets: const [],
        goals: const [],
      );

      expect(index.length, equals(2));
      expect(index.first.title, equals('Checking Account'));
      expect(index.last.title, equals('Groceries'));
    });

    test(
        'FuzzySearchEngine matches entity and command search queries accurately',
        () {
      const command = CommandItem(
        id: 'cmd-test',
        label: 'Create Transaction',
        description: 'New payment entry',
        targetRoute: '/transactions',
      );

      const indexItem = SearchResultItem(
        id: 'tx-100',
        title: 'Supermarket Purchase',
        subtitle: 'Groceries store',
        type: SearchResultType.transaction,
        targetRoute: '/transactions',
      );

      final queryResults = FuzzySearchEngine.search(
        query: 'Supermarket',
        indexItems: [indexItem],
        commands: [command],
      );

      expect(queryResults.length, equals(1));
      expect(queryResults.first.title, equals('Supermarket Purchase'));

      final commandResults = FuzzySearchEngine.search(
        query: 'Create',
        indexItems: [indexItem],
        commands: [command],
      );

      expect(commandResults.length, equals(1));
      expect(commandResults.first.title, equals('Create Transaction'));
    });
  });
}
