import 'package:flutter_test/flutter_test.dart';
import 'package:monetra/core/database/repositories/account_repository_impl.dart';
import 'package:monetra/core/domain/entities/account.dart';

void main() {
  late AccountRepositoryImpl repository;

  setUp(() {
    repository = AccountRepositoryImpl([]);
  });

  group('Accounts Module Unit & Repository Tests', () {
    test('createAccount persists account to list and updates stream', () async {
      final now = DateTime.now();
      final newAcc = Account(
        id: 'acc-test-101',
        name: 'Investment Fund',
        type: AccountType.investment,
        currency: 'USD',
        openingBalance: 10000.0,
        balance: 10500.0,
        icon: 'trending_up',
        colorHex: '#10B981',
        createdAt: now,
        updatedAt: now,
      );

      await repository.createAccount(newAcc);
      final accounts = await repository.getAllAccounts();

      expect(accounts.length, equals(1));
      expect(accounts.first.name, equals('Investment Fund'));
      expect(accounts.first.type, equals(AccountType.investment));
    });

    test('archiveAccount toggles archived state cleanly', () async {
      final now = DateTime.now();
      final newAcc = Account(
        id: 'acc-test-102',
        name: 'Old Wallet',
        type: AccountType.cash,
        currency: 'USD',
        openingBalance: 50.0,
        balance: 50.0,
        icon: 'wallet',
        colorHex: '#F59E0B',
        createdAt: now,
        updatedAt: now,
      );

      await repository.createAccount(newAcc);
      await repository.archiveAccount('acc-test-102', true);

      final activeAccounts =
          await repository.getAllAccounts(includeArchived: false);
      expect(activeAccounts.isEmpty, isTrue);

      final allAccounts =
          await repository.getAllAccounts(includeArchived: true);
      expect(allAccounts.length, equals(1));
      expect(allAccounts.first.isArchived, isTrue);
    });

    test('duplicateAccount creates twin record with copy suffix', () async {
      final now = DateTime.now();
      final original = Account(
        id: 'acc-orig-1',
        name: 'Main Vault',
        type: AccountType.checking,
        currency: 'EUR',
        openingBalance: 2000.0,
        balance: 2000.0,
        icon: 'vault',
        colorHex: '#6366F1',
        createdAt: now,
        updatedAt: now,
      );

      await repository.createAccount(original);
      final duplicate = await repository.duplicateAccount('acc-orig-1');

      expect(duplicate.name, equals('Main Vault (Copy)'));
      expect(duplicate.currency, equals('EUR'));
      expect(duplicate.id, isNot(equals('acc-orig-1')));
    });

    test('deleteAccount performs soft delete', () async {
      final now = DateTime.now();
      final acc = Account(
        id: 'acc-del-1',
        name: 'Temporary Account',
        type: AccountType.cash,
        currency: 'USD',
        openingBalance: 0.0,
        balance: 0.0,
        icon: 'cash',
        colorHex: '#06B6D4',
        createdAt: now,
        updatedAt: now,
      );

      await repository.createAccount(acc);
      await repository.deleteAccount('acc-del-1');

      final activeAccounts =
          await repository.getAllAccounts(includeArchived: true);
      expect(activeAccounts.isEmpty, isTrue);
    });
  });
}
