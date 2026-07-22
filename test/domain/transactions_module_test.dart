import 'package:flutter_test/flutter_test.dart';
import 'package:monetra/core/database/repositories/transaction_repository_impl.dart';
import 'package:monetra/core/domain/entities/transaction.dart';

void main() {
  late TransactionRepositoryImpl repository;

  setUp(() {
    repository = TransactionRepositoryImpl([]);
  });

  group('Transactions Module Unit & Feature Tests', () {
    test('createTransaction persists transaction and updates stream', () async {
      final now = DateTime.now();
      final tx = TransactionEntity(
        id: 'tx-unit-1',
        accountId: 'acc-1',
        amount: -45.0,
        date: now,
        description: 'Coffee Beans',
        createdAt: now,
        updatedAt: now,
      );

      await repository.createTransaction(tx);
      final transactions = await repository.getTransactions();

      expect(transactions.length, equals(1));
      expect(transactions.first.description, equals('Coffee Beans'));
    });

    test('createTransfer creates transfer record between two accounts',
        () async {
      final now = DateTime.now();
      await repository.createTransfer(
        sourceAccountId: 'acc-chk-1',
        destinationAccountId: 'acc-svg-1',
        amount: 250.0,
        date: now,
        description: 'Monthly Savings Auto-Transfer',
      );

      final list = await repository.getTransactions();
      expect(list.length, equals(1));
      expect(list.first.isTransfer, isTrue);
      expect(list.first.destinationAccountId, equals('acc-svg-1'));
    });

    test('bulkDeleteTransactions soft deletes specified records', () async {
      final now = DateTime.now();
      final tx1 = TransactionEntity(
          id: 'tx-b1',
          accountId: 'acc-1',
          amount: -10.0,
          date: now,
          description: 'Item 1',
          createdAt: now,
          updatedAt: now);
      final tx2 = TransactionEntity(
          id: 'tx-b2',
          accountId: 'acc-1',
          amount: -20.0,
          date: now,
          description: 'Item 2',
          createdAt: now,
          updatedAt: now);

      await repository.createTransaction(tx1);
      await repository.createTransaction(tx2);

      await repository.bulkDeleteTransactions(['tx-b1', 'tx-b2']);
      final active = await repository.getTransactions();

      expect(active.isEmpty, isTrue);
    });

    test('bulkUpdateCategory changes category across multiple records',
        () async {
      final now = DateTime.now();
      final tx1 = TransactionEntity(
          id: 'tx-c1',
          accountId: 'acc-1',
          categoryId: 'cat-old',
          amount: -15.0,
          date: now,
          description: 'Meal 1',
          createdAt: now,
          updatedAt: now);
      final tx2 = TransactionEntity(
          id: 'tx-c2',
          accountId: 'acc-1',
          categoryId: 'cat-old',
          amount: -25.0,
          date: now,
          description: 'Meal 2',
          createdAt: now,
          updatedAt: now);

      await repository.createTransaction(tx1);
      await repository.createTransaction(tx2);

      await repository
          .bulkUpdateCategory(ids: ['tx-c1', 'tx-c2'], categoryId: 'cat-new');
      final list = await repository.getTransactions();

      expect(list.every((t) => t.categoryId == 'cat-new'), isTrue);
    });
  });
}
