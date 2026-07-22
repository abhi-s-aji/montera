import 'dart:convert';

import 'package:monetra/core/domain/entities/account.dart';
import 'package:monetra/core/domain/entities/app_settings.dart';
import 'package:monetra/core/domain/entities/budget.dart';
import 'package:monetra/core/domain/entities/category.dart';
import 'package:monetra/core/domain/entities/goal.dart';
import 'package:monetra/core/domain/entities/transaction.dart';
import 'package:monetra/features/backup/domain/entities/backup_payload.dart';
import 'package:monetra/features/dashboard/domain/entities/dashboard_widget_config.dart';

class ChecksumVerifier {
  static String calculateChecksum(String content) {
    int hash = 0;
    for (int i = 0; i < content.length; i++) {
      hash = (hash * 31 + content.codeUnitAt(i)) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  static bool verify(String content, String expectedChecksum) {
    return calculateChecksum(content) == expectedChecksum;
  }
}

class ArchiveEncoder {
  static String encodeContainer(BackupPayloadContainer container) {
    final manifestJson = jsonEncode(container.manifest.toJson());
    final metadataJson = jsonEncode(container.metadata.toJson());

    final databaseJson = jsonEncode({
      'accounts': container.accounts.map((a) => a.toJson()).toList(),
      'categories': container.categories.map((c) => c.toJson()).toList(),
      'transactions': container.transactions.map((t) => t.toJson()).toList(),
      'budgets': container.budgets.map((b) => b.toJson()).toList(),
      'goals': container.goals.map((g) => g.toJson()).toList(),
    });

    final settingsJson = jsonEncode(container.settings.toJson());
    final dashboardJson =
        jsonEncode(container.dashboardLayout.map((d) => d.toJson()).toList());
    final pluginsJson = jsonEncode(container.pluginData);

    final checksums = {
      'manifest': ChecksumVerifier.calculateChecksum(manifestJson),
      'metadata': ChecksumVerifier.calculateChecksum(metadataJson),
      'database': ChecksumVerifier.calculateChecksum(databaseJson),
      'settings': ChecksumVerifier.calculateChecksum(settingsJson),
      'dashboard': ChecksumVerifier.calculateChecksum(dashboardJson),
      'plugins': ChecksumVerifier.calculateChecksum(pluginsJson),
    };

    final globalChecksum =
        ChecksumVerifier.calculateChecksum(jsonEncode(checksums));

    final archiveMap = {
      'manifest.json': manifestJson,
      'metadata.json': metadataJson,
      'database.json': databaseJson,
      'settings.json': settingsJson,
      'dashboard.json': dashboardJson,
      'plugins.json': pluginsJson,
      'checksums': checksums,
      'globalChecksum': globalChecksum,
    };

    return jsonEncode(archiveMap);
  }
}

class ArchiveDecoder {
  static BackupPayloadContainer decodeContainer(String rawJson) {
    final Map<String, dynamic> archiveMap = jsonDecode(rawJson);

    final manifestJsonStr = archiveMap['manifest.json'] as String;
    final metadataJsonStr = archiveMap['metadata.json'] as String;
    final databaseJsonStr = archiveMap['database.json'] as String;
    final settingsJsonStr = archiveMap['settings.json'] as String;
    final dashboardJsonStr = archiveMap['dashboard.json'] as String;
    final pluginsJsonStr = archiveMap['plugins.json'] as String? ?? '{}';

    final manifest = BackupManifest.fromJson(jsonDecode(manifestJsonStr));
    final metadata = BackupMetadata.fromJson(jsonDecode(metadataJsonStr));

    final dbMap = jsonDecode(databaseJsonStr) as Map<String, dynamic>;
    final accounts = (dbMap['accounts'] as List? ?? [])
        .map((a) => Account.fromJson(a))
        .toList();
    final categories = (dbMap['categories'] as List? ?? [])
        .map((c) => Category.fromJson(c))
        .toList();
    final transactions = (dbMap['transactions'] as List? ?? [])
        .map((t) => TransactionEntity.fromJson(t))
        .toList();
    final budgets = (dbMap['budgets'] as List? ?? [])
        .map((b) => Budget.fromJson(b))
        .toList();
    final goals =
        (dbMap['goals'] as List? ?? []).map((g) => Goal.fromJson(g)).toList();

    final settings = AppSettings.fromJson(jsonDecode(settingsJsonStr));
    final dashboardLayout = (jsonDecode(dashboardJsonStr) as List? ?? [])
        .map((d) => DashboardWidgetConfig.fromJson(d))
        .toList();
    final pluginData =
        jsonDecode(pluginsJsonStr) as Map<String, dynamic>? ?? {};

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
      pluginData: pluginData,
    );
  }

  static bool validateArchive(String rawJson) {
    try {
      final Map<String, dynamic> archiveMap = jsonDecode(rawJson);
      if (!archiveMap.containsKey('manifest.json') ||
          !archiveMap.containsKey('database.json')) {
        return false;
      }
      final checksums = archiveMap['checksums'] as Map<String, dynamic>?;
      if (checksums == null) return false;

      final manifestJsonStr = archiveMap['manifest.json'] as String;
      final databaseJsonStr = archiveMap['database.json'] as String;

      if (!ChecksumVerifier.verify(
          manifestJsonStr, checksums['manifest'] as String)) return false;
      if (!ChecksumVerifier.verify(
          databaseJsonStr, checksums['database'] as String)) return false;

      return true;
    } catch (_) {
      return false;
    }
  }
}
