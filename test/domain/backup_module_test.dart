import 'package:flutter_test/flutter_test.dart';
import 'package:monetra/core/domain/entities/account.dart';
import 'package:monetra/core/domain/entities/app_settings.dart';
import 'package:monetra/core/domain/entities/category.dart';
import 'package:monetra/core/domain/entities/transaction.dart';
import 'package:monetra/features/backup/domain/entities/backup_payload.dart';
import 'package:monetra/features/backup/services/backup_engine_services.dart';

void main() {
  group('Monetra Backup, Restore & Data Migration Engine Tests', () {
    late BackupPayloadContainer testContainer;

    setUp(() {
      final manifest = BackupManifest(
        backupVersion: 1,
        appVersion: '1.0.0+1',
        dbSchemaVersion: 1,
        createdTimestamp: DateTime(2026, 7, 22),
        platform: 'Linux',
        locale: 'en_US',
        compressionMethod: 'none',
        encryptionStatus: 'none',
        backupUuid: 'test-backup-uuid-123',
        deviceInfo: const {'os': 'Linux'},
        checksumAlgorithm: 'SHA-256',
        totalArchiveSize: 500,
      );

      final metadata = const BackupMetadata(
        transactionCount: 1,
        accountCount: 1,
        categoryCount: 1,
        budgetCount: 0,
        goalCount: 0,
        attachmentCount: 0,
        pluginCount: 0,
        backupDurationMs: 12.5,
        generatorVersion: '1.0.0',
      );

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

      final transaction = TransactionEntity(
        id: 'tx-1',
        accountId: 'acc-1',
        categoryId: 'cat-1',
        amount: -50.0,
        type: TransactionType.expense,
        date: DateTime(2026, 7, 22),
        description: 'Supermarket Groceries',
        createdAt: DateTime(2026, 7, 22),
        updatedAt: DateTime(2026, 7, 22),
      );

      testContainer = BackupPayloadContainer(
        manifest: manifest,
        metadata: metadata,
        accounts: [account],
        categories: [category],
        transactions: [transaction],
        budgets: const [],
        goals: const [],
        settings: const AppSettings(),
        dashboardLayout: const [],
      );
    });

    test(
        'ArchiveEncoder serializes container and calculates valid SHA-256 checksums',
        () {
      final jsonStr = ArchiveEncoder.encodeContainer(testContainer);
      expect(jsonStr, isNotEmpty);
      expect(jsonStr.contains('manifest.json'), isTrue);
      expect(jsonStr.contains('database.json'), isTrue);
      expect(jsonStr.contains('checksums'), isTrue);
    });

    test(
        'ArchiveDecoder validates clean archive signature and parses payload correctly',
        () {
      final jsonStr = ArchiveEncoder.encodeContainer(testContainer);
      final isValid = ArchiveDecoder.validateArchive(jsonStr);
      expect(isValid, isTrue);

      final decodedContainer = ArchiveDecoder.decodeContainer(jsonStr);
      expect(
          decodedContainer.manifest.backupUuid, equals('test-backup-uuid-123'));
      expect(decodedContainer.accounts.length, equals(1));
      expect(decodedContainer.accounts.first.name, equals('Checking Account'));
      expect(decodedContainer.transactions.length, equals(1));
      expect(decodedContainer.transactions.first.description,
          equals('Supermarket Groceries'));
    });

    test(
        'ArchiveDecoder rejects corrupted payload string with invalid checksum signature',
        () {
      final jsonStr = ArchiveEncoder.encodeContainer(testContainer);
      final tamperedJsonStr =
          jsonStr.replaceAll('Checking Account', 'Hacked Account');

      final isValid = ArchiveDecoder.validateArchive(tamperedJsonStr);
      expect(isValid, isFalse);
    });

    test('ChecksumVerifier calculates deterministic checksum hashes', () {
      const content = 'Monetra Offline Vault Payload Content';
      final hash1 = ChecksumVerifier.calculateChecksum(content);
      final hash2 = ChecksumVerifier.calculateChecksum(content);

      expect(hash1, equals(hash2));
      expect(hash1.length, equals(8));
    });
  });
}
