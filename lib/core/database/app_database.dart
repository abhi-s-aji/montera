import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Accounts,
  Categories,
  Merchants,
  Transactions,
  Tags,
  TransactionTags,
  Budgets,
  Goals,
  Attachments,
  Currencies,
  ExchangeRates,
  Settings,
  DashboardLayouts,
  DashboardWidgets,
  Notifications,
  BackupMetadata,
  PluginMetadata,
  FutureSyncMetadata,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // Prepared for future schema evolution & version migrations
        },
        beforeOpen: (details) async {
          // Enforce foreign key constraints
          await customStatement('PRAGMA foreign_keys = ON;');
          // Enable WAL mode for high concurrency
          await customStatement('PRAGMA journal_mode = WAL;');
        },
      );

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'monetra_vault.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
