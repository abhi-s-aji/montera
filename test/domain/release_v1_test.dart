import 'package:flutter_test/flutter_test.dart';

import 'package:monetra/core/domain/entities/account.dart';
import 'package:monetra/core/domain/entities/recurring_schedule.dart';
import 'package:monetra/core/domain/entities/transaction.dart';
import 'package:monetra/features/automation/services/recurring_engine_services.dart';

import 'package:monetra/features/search/domain/entities/search_result.dart';
import 'package:monetra/features/search/services/search_index_engine.dart';
import 'package:monetra/features/security/services/security_services.dart';

void main() {
  group(
      'Monetra v1.0 Final Release Engineering & Integration Verification Suite',
      () {
    test('Verify Core Domain Entities Integration', () {
      final account = Account(
        id: 'acc-release',
        name: 'Master Vault',
        type: AccountType.checking,
        openingBalance: 10000.0,
        balance: 10000.0,
        icon: 'account_balance',
        colorHex: '#2196F3',
        currency: 'USD',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final transaction = TransactionEntity(
        id: 'tx-release',
        accountId: account.id,
        amount: -150.0,
        type: TransactionType.expense,
        date: DateTime(2026, 7, 22),
        description: 'Release Verification Purchase',
        createdAt: DateTime(2026, 7, 22),
        updatedAt: DateTime(2026, 7, 22),
      );

      expect(
          transaction.description, contains('Release Verification Purchase'));
      expect(transaction.amount, equals(-150.0));
    });

    test('Verify Security & Privacy Engine Operations', () {
      const rawPin = '9876';
      final hash = PinHasher.hashPin(rawPin);
      expect(PinHasher.verifyPin('9876', hash), isTrue);

      final masked = PrivacyMasker.maskAmount(1000.0, 'USD', true);
      expect(masked, equals('••••••'));
    });

    test('Verify Universal Search Index & Command Palette Matching', () {
      const command = CommandItem(
        id: 'cmd-release',
        label: 'Open Dashboard',
        description: 'Navigate to overview',
        targetRoute: '/dashboard',
      );

      final results = FuzzySearchEngine.search(
        query: 'Dashboard',
        indexItems: const [],
        commands: [command],
      );

      expect(results.length, equals(1));
      expect(results.first.targetRoute, equals('/dashboard'));
    });

    test('Verify Recurrence Calculator Deterministic Scheduling', () {
      final startDate = DateTime(2026, 7, 22);
      final nextMonthly = RecurrenceCalculator.calculateNextExecution(
        fromDate: startDate,
        frequency: RecurrenceFrequency.monthly,
      );

      expect(nextMonthly, equals(DateTime(2026, 8, 22)));
    });
  });
}
