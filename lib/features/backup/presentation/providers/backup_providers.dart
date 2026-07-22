import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monetra/core/providers/account_providers.dart';
import 'package:monetra/core/providers/budget_providers.dart';
import 'package:monetra/core/providers/category_providers.dart';
import 'package:monetra/core/providers/goal_providers.dart';
import 'package:monetra/core/providers/settings_providers.dart';
import 'package:monetra/core/providers/transaction_providers.dart';
import 'package:monetra/features/backup/domain/entities/backup_payload.dart';
import 'package:monetra/features/dashboard/presentation/providers/dashboard_providers.dart';

final backupHistoryProvider =
    StateProvider<List<BackupPayloadContainer>>((ref) => []);

final selectedRestoreOptionsProvider =
    StateProvider<RestoreOptions>((ref) => const RestoreOptions());

final selectedBackupForRestoreProvider =
    StateProvider<BackupPayloadContainer?>((ref) => null);

final restoreReportProvider = StateProvider<RestoreReport?>((ref) => null);

final createBackupContainerProvider = Provider<BackupPayloadContainer>((ref) {
  final accounts = ref.watch(accountsStreamProvider).value ?? [];
  final categories = ref.watch(categoriesStreamProvider).value ?? [];
  final transactions = ref.watch(transactionsStreamProvider).value ?? [];
  final budgets = ref.watch(budgetsStreamProvider).value ?? [];
  final goals = ref.watch(goalsStreamProvider).value ?? [];
  final settings = ref.watch(settingsNotifierProvider);
  final dashboardLayout = ref.watch(dashboardWidgetLayoutProvider);

  final manifest = BackupManifest(
    backupVersion: 1,
    appVersion: '1.0.0+1',
    dbSchemaVersion: 1,
    createdTimestamp: DateTime.now(),
    platform: 'Linux',
    locale: 'en_US',
    compressionMethod: 'none',
    encryptionStatus: 'none',
    backupUuid: 'monetra-bup-${DateTime.now().millisecondsSinceEpoch}',
    deviceInfo: const {'os': 'Linux', 'architecture': 'x86_64'},
    checksumAlgorithm: 'SHA-256',
    totalArchiveSize: 1024,
  );

  final metadata = BackupMetadata(
    transactionCount: transactions.length,
    accountCount: accounts.length,
    categoryCount: categories.length,
    budgetCount: budgets.length,
    goalCount: goals.length,
    attachmentCount: 0,
    pluginCount: 0,
    backupDurationMs: 45.0,
    generatorVersion: '1.0.0',
  );

  return BackupPayloadContainer(
    manifest: manifest,
    metadata: metadata,
    accounts: accounts,
    categories: categories,
    transactions: transactions,
    budgets: budgets,
    goals: goals,
    settings: settings,
    dashboardLayout: dashboardLayout,
  );
});
