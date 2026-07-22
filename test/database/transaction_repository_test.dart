import 'package:flutter_test/flutter_test.dart';
import 'package:monetra/core/database/repositories/transaction_repository_impl.dart';
import 'package:monetra/core/domain/entities/transaction.dart';

void main() {
  group('TransactionRepositoryImpl Tests', () {
    late TransactionRepositoryImpl repository;

    setUp(() {
      repository = TransactionRepositoryImpl([]);
    });

    test('createTransaction adds entry to repository and updates stream',
        () async {
      final now = DateTime.now();
      final newTx = TransactionEntity(
        id: 'tx-test-1',
        accountId: 'acc-1',
        amount: -50.0,
        date: now,
        description: 'Test Dinner',
        createdAt: now,
        updatedAt: now,
      );

      await repository.createTransaction(newTx);
      final list = await repository.getTransactions();

      expect(list.length, 1);
      expect(list.first.description, 'Test Dinner');
    });

    test(
        'getTransactions filters by search query accurately across description and tags',
        () async {
      final now = DateTime.now();
      await repository.createTransaction(TransactionEntity(
        id: '1',
        accountId: 'a1',
        amount: -20,
        date: now,
        description: 'Target Groceries',
        tags: const ['food'],
        createdAt: now,
        updatedAt: now,
      ));
      await repository.createTransaction(TransactionEntity(
        id: '2',
        accountId: 'a1',
        amount: -100,
        date: now,
        description: 'Apple Store Hardware',
        tags: const ['tech'],
        createdAt: now,
        updatedAt: now,
      ));

      final searchFood = await repository.getTransactions(searchQuery: 'food');
      expect(searchFood.length, 1);
      expect(searchFood.first.id, '1');

      final searchApple =
          await repository.getTransactions(searchQuery: 'Apple');
      expect(searchApple.length, 1);
      expect(searchApple.first.id, '2');
    });

    test('deleteTransaction performs soft delete', () async {
      final now = DateTime.now();
      final tx = TransactionEntity(
        id: 'del-1',
        accountId: 'a1',
        amount: -10,
        date: now,
        description: 'Coffee',
        createdAt: now,
        updatedAt: now,
      );

      await repository.createTransaction(tx);
      await repository.deleteTransaction('del-1');

      final activeList = await repository.getTransactions();
      expect(activeList.isEmpty, true);

      final softDeletedTx = await repository.getTransactionById('del-1');
      expect(softDeletedTx, null);
    });
  });
}
