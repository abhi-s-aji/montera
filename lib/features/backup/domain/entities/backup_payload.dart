import 'package:equatable/equatable.dart';

import 'package:monetra/core/domain/entities/account.dart';
import 'package:monetra/core/domain/entities/app_settings.dart';
import 'package:monetra/core/domain/entities/budget.dart';
import 'package:monetra/core/domain/entities/category.dart';
import 'package:monetra/core/domain/entities/goal.dart';
import 'package:monetra/core/domain/entities/transaction.dart';
import 'package:monetra/features/dashboard/domain/entities/dashboard_widget_config.dart';

class BackupManifest extends Equatable {
  final int backupVersion;
  final String appVersion;
  final int dbSchemaVersion;
  final DateTime createdTimestamp;
  final String platform;
  final String locale;
  final String compressionMethod;
  final String encryptionStatus;
  final String backupUuid;
  final Map<String, String> deviceInfo;
  final String checksumAlgorithm;
  final int totalArchiveSize;

  const BackupManifest({
    required this.backupVersion,
    required this.appVersion,
    required this.dbSchemaVersion,
    required this.createdTimestamp,
    required this.platform,
    required this.locale,
    required this.compressionMethod,
    required this.encryptionStatus,
    required this.backupUuid,
    required this.deviceInfo,
    required this.checksumAlgorithm,
    required this.totalArchiveSize,
  });

  Map<String, dynamic> toJson() => {
        'backupVersion': backupVersion,
        'appVersion': appVersion,
        'dbSchemaVersion': dbSchemaVersion,
        'createdTimestamp': createdTimestamp.toIso8601String(),
        'platform': platform,
        'locale': locale,
        'compressionMethod': compressionMethod,
        'encryptionStatus': encryptionStatus,
        'backupUuid': backupUuid,
        'deviceInfo': deviceInfo,
        'checksumAlgorithm': checksumAlgorithm,
        'totalArchiveSize': totalArchiveSize,
      };

  factory BackupManifest.fromJson(Map<String, dynamic> json) {
    return BackupManifest(
      backupVersion: json['backupVersion'] as int? ?? 1,
      appVersion: json['appVersion'] as String? ?? '1.0.0',
      dbSchemaVersion: json['dbSchemaVersion'] as int? ?? 1,
      createdTimestamp: DateTime.parse(json['createdTimestamp'] as String? ??
          DateTime.now().toIso8601String()),
      platform: json['platform'] as String? ?? 'unknown',
      locale: json['locale'] as String? ?? 'en_US',
      compressionMethod: json['compressionMethod'] as String? ?? 'none',
      encryptionStatus: json['encryptionStatus'] as String? ?? 'none',
      backupUuid: json['backupUuid'] as String? ?? '',
      deviceInfo: Map<String, String>.from(json['deviceInfo'] as Map? ?? {}),
      checksumAlgorithm: json['checksumAlgorithm'] as String? ?? 'SHA-256',
      totalArchiveSize: json['totalArchiveSize'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        backupVersion,
        appVersion,
        dbSchemaVersion,
        createdTimestamp,
        platform,
        locale,
        compressionMethod,
        encryptionStatus,
        backupUuid,
        deviceInfo,
        checksumAlgorithm,
        totalArchiveSize,
      ];
}

class BackupMetadata extends Equatable {
  final int transactionCount;
  final int accountCount;
  final int categoryCount;
  final int budgetCount;
  final int goalCount;
  final int attachmentCount;
  final int pluginCount;
  final double backupDurationMs;
  final String generatorVersion;

  const BackupMetadata({
    required this.transactionCount,
    required this.accountCount,
    required this.categoryCount,
    required this.budgetCount,
    required this.goalCount,
    required this.attachmentCount,
    required this.pluginCount,
    required this.backupDurationMs,
    required this.generatorVersion,
  });

  Map<String, dynamic> toJson() => {
        'transactionCount': transactionCount,
        'accountCount': accountCount,
        'categoryCount': categoryCount,
        'budgetCount': budgetCount,
        'goalCount': goalCount,
        'attachmentCount': attachmentCount,
        'pluginCount': pluginCount,
        'backupDurationMs': backupDurationMs,
        'generatorVersion': generatorVersion,
      };

  factory BackupMetadata.fromJson(Map<String, dynamic> json) {
    return BackupMetadata(
      transactionCount: json['transactionCount'] as int? ?? 0,
      accountCount: json['accountCount'] as int? ?? 0,
      categoryCount: json['categoryCount'] as int? ?? 0,
      budgetCount: json['budgetCount'] as int? ?? 0,
      goalCount: json['goalCount'] as int? ?? 0,
      attachmentCount: json['attachmentCount'] as int? ?? 0,
      pluginCount: json['pluginCount'] as int? ?? 0,
      backupDurationMs: (json['backupDurationMs'] as num? ?? 0).toDouble(),
      generatorVersion: json['generatorVersion'] as String? ?? '1.0.0',
    );
  }

  @override
  List<Object?> get props => [
        transactionCount,
        accountCount,
        categoryCount,
        budgetCount,
        goalCount,
        attachmentCount,
        pluginCount,
        backupDurationMs,
        generatorVersion,
      ];
}

class BackupPayloadContainer extends Equatable {
  final BackupManifest manifest;
  final BackupMetadata metadata;
  final List<Account> accounts;
  final List<Category> categories;
  final List<TransactionEntity> transactions;
  final List<Budget> budgets;
  final List<Goal> goals;
  final AppSettings settings;
  final List<DashboardWidgetConfig> dashboardLayout;
  final Map<String, dynamic> pluginData;
  final Map<String, String> sectionChecksums;

  const BackupPayloadContainer({
    required this.manifest,
    required this.metadata,
    required this.accounts,
    required this.categories,
    required this.transactions,
    required this.budgets,
    required this.goals,
    required this.settings,
    required this.dashboardLayout,
    this.pluginData = const {},
    this.sectionChecksums = const {},
  });

  @override
  List<Object?> get props => [
        manifest,
        metadata,
        accounts,
        categories,
        transactions,
        budgets,
        goals,
        settings,
        dashboardLayout,
        pluginData,
        sectionChecksums,
      ];
}

enum ConflictStrategy { keepExisting, replaceExisting, keepNewest, keepOldest }

class RestoreOptions extends Equatable {
  final bool restoreAccounts;
  final bool restoreCategories;
  final bool restoreTransactions;
  final bool restoreBudgets;
  final bool restoreGoals;
  final bool restoreSettings;
  final bool restoreDashboard;
  final ConflictStrategy conflictStrategy;

  const RestoreOptions({
    this.restoreAccounts = true,
    this.restoreCategories = true,
    this.restoreTransactions = true,
    this.restoreBudgets = true,
    this.restoreGoals = true,
    this.restoreSettings = true,
    this.restoreDashboard = true,
    this.conflictStrategy = ConflictStrategy.replaceExisting,
  });

  @override
  List<Object?> get props => [
        restoreAccounts,
        restoreCategories,
        restoreTransactions,
        restoreBudgets,
        restoreGoals,
        restoreSettings,
        restoreDashboard,
        conflictStrategy,
      ];
}

class RestoreReport extends Equatable {
  final int accountsRestored;
  final int categoriesRestored;
  final int transactionsRestored;
  final int budgetsRestored;
  final int goalsRestored;
  final int settingsRestored;
  final int skippedRecords;
  final int conflictsResolved;
  final List<String> warnings;
  final List<String> errors;
  final double elapsedTimeMs;

  const RestoreReport({
    required this.accountsRestored,
    required this.categoriesRestored,
    required this.transactionsRestored,
    required this.budgetsRestored,
    required this.goalsRestored,
    required this.settingsRestored,
    required this.skippedRecords,
    required this.conflictsResolved,
    required this.warnings,
    required this.errors,
    required this.elapsedTimeMs,
  });

  @override
  List<Object?> get props => [
        accountsRestored,
        categoriesRestored,
        transactionsRestored,
        budgetsRestored,
        goalsRestored,
        settingsRestored,
        skippedRecords,
        conflictsResolved,
        warnings,
        errors,
        elapsedTimeMs,
      ];
}
