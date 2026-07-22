import 'package:flutter_test/flutter_test.dart';
import 'package:monetra/core/domain/entities/account.dart';

void main() {
  group('Account Entity Tests', () {
    test('Account copyWith correctly updates properties while retaining others',
        () {
      final now = DateTime.now();
      final original = Account(
        id: 'acc-1',
        name: 'Checking',
        type: AccountType.checking,
        currency: 'USD',
        openingBalance: 1000.0,
        balance: 1000.0,
        icon: 'account_balance',
        colorHex: '#6366F1',
        createdAt: now,
        updatedAt: now,
      );

      final updated =
          original.copyWith(balance: 1250.50, name: 'Main Checking');

      expect(updated.id, 'acc-1');
      expect(updated.name, 'Main Checking');
      expect(updated.balance, 1250.50);
      expect(updated.currency, 'USD');
      expect(updated.version, 1);
      expect(updated.isDeleted, false);
    });

    test('Account Equatable props comparison works as expected', () {
      final now = DateTime.now();
      final acc1 = Account(
        id: 'acc-1',
        name: 'Checking',
        type: AccountType.checking,
        currency: 'USD',
        openingBalance: 1000.0,
        balance: 1000.0,
        icon: 'account_balance',
        colorHex: '#6366F1',
        createdAt: now,
        updatedAt: now,
      );

      final acc2 = Account(
        id: 'acc-1',
        name: 'Checking',
        type: AccountType.checking,
        currency: 'USD',
        openingBalance: 1000.0,
        balance: 1000.0,
        icon: 'account_balance',
        colorHex: '#6366F1',
        createdAt: now,
        updatedAt: now,
      );

      expect(acc1, equals(acc2));
    });
  });
}
