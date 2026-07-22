import 'dart:ffi';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monetra/core/database/app_database.dart';
import 'package:sqlite3/open.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase database;

  setUpAll(() {
    open.overrideFor(
        OperatingSystem.linux, () => DynamicLibrary.open('libsqlite3.so.0'));
  });

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('AppDatabase Drift Schema & Persistence Tests', () {
    test('Database initializes cleanly and schema version is 1', () {
      expect(database.schemaVersion, equals(1));
    });

    test('Can insert and query Account record', () async {
      await database.into(database.accounts).insert(
            AccountsCompanion.insert(
              id: 'acc-test-1',
              name: 'Checking Test Account',
              type: 'checking',
              balance: const Value(1500.50),
              currency: const Value('USD'),
            ),
          );

      final accounts = await database.select(database.accounts).get();
      expect(accounts.length, equals(1));
      expect(accounts.first.id, equals('acc-test-1'));
      expect(accounts.first.name, equals('Checking Test Account'));
      expect(accounts.first.balance, equals(1500.50));
    });

    test('Can insert and query Transaction record with foreign key reference',
        () async {
      // Insert prerequisite Account & Category
      await database.into(database.accounts).insert(
            AccountsCompanion.insert(
              id: 'acc-test-1',
              name: 'Checking Test Account',
              type: 'checking',
            ),
          );

      await database.into(database.categories).insert(
            CategoriesCompanion.insert(
              id: 'cat-test-1',
              name: 'Groceries',
              type: 'expense',
            ),
          );

      await database.into(database.transactions).insert(
            TransactionsCompanion.insert(
              id: 'tx-test-1',
              accountId: 'acc-test-1',
              categoryId: const Value('cat-test-1'),
              amount: -85.20,
              date: DateTime.now(),
              description: 'Organic Market',
            ),
          );

      final txList = await database.select(database.transactions).get();
      expect(txList.length, equals(1));
      expect(txList.first.id, equals('tx-test-1'));
      expect(txList.first.amount, equals(-85.20));
      expect(txList.first.description, equals('Organic Market'));
    });

    test('Soft delete flag operates correctly on Transactions', () async {
      await database.into(database.accounts).insert(
            AccountsCompanion.insert(
              id: 'acc-test-1',
              name: 'Checking Test Account',
              type: 'checking',
            ),
          );

      await database.into(database.transactions).insert(
            TransactionsCompanion.insert(
              id: 'tx-test-2',
              accountId: 'acc-test-1',
              amount: -12.00,
              date: DateTime.now(),
              description: 'Coffee',
            ),
          );

      // Perform soft delete
      await (database.update(database.transactions)
            ..where((t) => t.id.equals('tx-test-2')))
          .write(
        const TransactionsCompanion(isDeleted: Value(true)),
      );

      final activeTx = await (database.select(database.transactions)
            ..where((t) => t.isDeleted.equals(false)))
          .get();
      expect(activeTx.isEmpty, isTrue);

      final deletedTx = await (database.select(database.transactions)
            ..where((t) => t.isDeleted.equals(true)))
          .get();
      expect(deletedTx.length, equals(1));
      expect(deletedTx.first.id, equals('tx-test-2'));
    });
  });
}
