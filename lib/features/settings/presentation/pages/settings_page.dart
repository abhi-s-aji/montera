import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/entities/app_settings.dart';
import '../../../../core/providers/account_providers.dart';
import '../../../../core/providers/category_providers.dart';
import '../../../../core/providers/settings_providers.dart';
import '../../../../core/providers/transaction_providers.dart';
import '../../../../core/theme/monetra_colors.dart';
import '../../../../core/theme/monetra_design_system.dart';
import '../../../../core/widgets/monetra_card.dart';

// Embedded settings sub-pages
import 'package:monetra/features/security/presentation/pages/security_settings_page.dart';
import 'package:monetra/features/backup/presentation/pages/backup_page.dart';
import 'package:monetra/features/import/presentation/pages/import_page.dart';
import 'package:monetra/features/automation/presentation/pages/recurring_page.dart';
import 'package:monetra/features/plugins/presentation/pages/plugin_manager_page.dart';
import 'package:monetra/features/performance/presentation/pages/performance_page.dart';

enum SettingsSection {
  appearance,
  security,
  data,
  automation,
  plugins,
  developer,
}

class SettingsSectionData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget widget;

  const SettingsSectionData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.widget,
  });
}

final activeSettingsSectionProvider = StateProvider<SettingsSection?>((ref) => null);

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;
    final activeSection = ref.watch(activeSettingsSectionProvider);

    final sections = {
      SettingsSection.appearance: SettingsSectionData(
        title: 'Appearance',
        subtitle: 'Theme, accent color, and custom corners',
        icon: Icons.palette_outlined,
        widget: const AppearanceSettingsView(),
      ),
      SettingsSection.security: SettingsSectionData(
        title: 'Security',
        subtitle: 'Vault lock, biometrics, and privacy filters',
        icon: Icons.security_outlined,
        widget: const SecuritySettingsPage(),
      ),
      SettingsSection.data: SettingsSectionData(
        title: 'Data & Imports',
        subtitle: 'Backup, restore, CSV file imports, and formats',
        icon: Icons.import_export_rounded,
        widget: const DataSettingsView(),
      ),
      SettingsSection.automation: SettingsSectionData(
        title: 'Automation',
        subtitle: 'Scheduled events and recurrence logs',
        icon: Icons.autorenew_outlined,
        widget: const RecurringPage(),
      ),
      SettingsSection.plugins: SettingsSectionData(
        title: 'Plugins',
        subtitle: 'Manage sandboxed plugins & permissions',
        icon: Icons.extension_outlined,
        widget: const PluginManagerPage(),
      ),
      SettingsSection.developer: SettingsSectionData(
        title: 'Developer Options',
        subtitle: 'Diagnostic performance stats and logs',
        icon: Icons.developer_mode_outlined,
        widget: const PerformancePage(),
      ),
    };

    if (isMobile) {
      if (activeSection != null) {
        final secData = sections[activeSection]!;
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            if (didPop) return;
            ref.read(activeSettingsSectionProvider.notifier).state = null;
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(secData.title),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  ref.read(activeSettingsSectionProvider.notifier).state = null;
                },
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: secData.widget,
            ),
          ),
        );
      }

      return Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              'System Settings',
              style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Configure workspace settings, automation, and backup options',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            ...sections.entries.map((e) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(e.value.icon, color: theme.colorScheme.primary),
                  title: Text(e.value.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(e.value.subtitle),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    ref.read(activeSettingsSectionProvider.notifier).state = e.key;
                  },
                ),
              );
            }).toList(),
          ],
        ),
      );
    }

    // Desktop master-detail layout
    final currentSection = activeSection ?? SettingsSection.appearance;
    final secData = sections[currentSection]!;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sidebar menu
          SizedBox(
            width: 240,
            child: ListView(
              children: [
                Text(
                  'System Settings',
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...sections.entries.map((e) {
                  final isSelected = currentSection == e.key;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: ListTile(
                      selected: isSelected,
                      leading: Icon(e.value.icon),
                      title: Text(e.value.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      onTap: () {
                        ref.read(activeSettingsSectionProvider.notifier).state = e.key;
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          const VerticalDivider(width: 48),
          // Detail body
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  secData.title,
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  secData.subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: secData.widget,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppearanceSettingsView extends ConsumerWidget {
  const AppearanceSettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsNotifierProvider);
    final settingsNotifier = ref.read(settingsNotifierProvider.notifier);

    final accentColors = [
      '#6366F1',
      '#10B981',
      '#EC4899',
      '#F59E0B',
      '#06B6D4',
      '#8B5CF6'
    ];

    final isMobile = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MonetraCard(
            padding: const EdgeInsets.all(MonetraDesignSystem.spaceXL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Theme & Appearance',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                if (isMobile)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ChoiceChip(
                        label: const Center(child: Text('Dark')),
                        selected: settings.themeMode == AppThemeMode.dark,
                        onSelected: (_) =>
                            settingsNotifier.updateThemeMode(AppThemeMode.dark),
                      ),
                      const SizedBox(height: 8),
                      ChoiceChip(
                        label: const Center(child: Text('OLED')),
                        selected: settings.themeMode == AppThemeMode.oled,
                        onSelected: (_) =>
                            settingsNotifier.updateThemeMode(AppThemeMode.oled),
                      ),
                      const SizedBox(height: 8),
                      ChoiceChip(
                        label: const Center(child: Text('Light')),
                        selected: settings.themeMode == AppThemeMode.light,
                        onSelected: (_) => settingsNotifier
                            .updateThemeMode(AppThemeMode.light),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Dark')),
                          selected: settings.themeMode == AppThemeMode.dark,
                          onSelected: (_) => settingsNotifier
                              .updateThemeMode(AppThemeMode.dark),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('OLED')),
                          selected: settings.themeMode == AppThemeMode.oled,
                          onSelected: (_) => settingsNotifier
                              .updateThemeMode(AppThemeMode.oled),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Light')),
                          selected: settings.themeMode == AppThemeMode.light,
                          onSelected: (_) => settingsNotifier
                              .updateThemeMode(AppThemeMode.light),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                Text('Accent Color',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyMedium?.color)),
                const SizedBox(height: 12),
                Row(
                  children: accentColors.map((hex) {
                    final color = MonetraColors.hexToColor(hex);
                    final isSelected = settings.primaryAccentHex == hex;
                    return GestureDetector(
                      onTap: () => settingsNotifier.updatePrimaryAccent(hex),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 20)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Text('Corner Radius (${settings.borderRadius.toInt()}px)',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyMedium?.color)),
                Slider(
                  value: settings.borderRadius,
                  min: 4,
                  max: 24,
                  divisions: 5,
                  onChanged: (val) => settingsNotifier.updateBorderRadius(val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DataSettingsView extends ConsumerWidget {
  const DataSettingsView({super.key});

  void _exportJsonData(BuildContext context, WidgetRef ref) {
    final accounts = ref.read(accountsStreamProvider).value ?? [];
    final categories = ref.read(categoriesStreamProvider).value ?? [];
    final transactions = ref.read(transactionsStreamProvider).value ?? [];

    final exportData = {
      'app': 'Monetra',
      'version': '1.0.0',
      'exported_at': DateTime.now().toIso8601String(),
      'accounts': accounts
          .map((a) => {
                'id': a.id,
                'name': a.name,
                'balance': a.balance,
                'currency': a.currency
              })
          .toList(),
      'categories': categories
          .map((c) => {'id': c.id, 'name': c.name, 'type': c.type.name})
          .toList(),
      'transactions': transactions
          .map((t) => {
                'id': t.id,
                'description': t.description,
                'amount': t.amount,
                'date': t.date.toIso8601String(),
                'tags': t.tags,
              })
          .toList(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Export Local JSON Backup'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: SelectableText(
              jsonString,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settingsNotifier = ref.read(settingsNotifierProvider.notifier);

    return SingleChildScrollView(
      child: Column(
        children: [
          MonetraCard(
            padding: const EdgeInsets.all(MonetraDesignSystem.spaceXL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Backup & Ingestion Tools',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.backup_rounded),
                  title: const Text('Backup Studio'),
                  subtitle: const Text('Export and restore encrypted snapshots with verification checksums'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BackupPage()));
                  },
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.upload_file_rounded),
                  title: const Text('Import Studio'),
                  subtitle: const Text('Ingest CSV/JSON files and map spreadsheet columns to fields'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ImportPage()));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          MonetraCard(
            padding: const EdgeInsets.all(MonetraDesignSystem.spaceXL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Data Portability & Ownership',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(
                    'Export your complete financial records into open formats (JSON / CSV). No lock-in.',
                    style: TextStyle(
                        fontSize: 13,
                        color: theme.textTheme.bodyMedium?.color
                            ?.withValues(alpha: 0.7))),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => _exportJsonData(context, ref),
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text('Export Local JSON Backup'),
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: MonetraColors.expenseRed,
                    side: const BorderSide(color: MonetraColors.expenseRed),
                  ),
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Factory Reset Database?'),
                        content: const Text(
                          'WARNING: This will permanently erase all local bank accounts, categories, and transaction records on this device. This operation cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: MonetraColors.expenseRed,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              Navigator.of(ctx).pop();
                              await settingsNotifier.resetToDefaults();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Database reset to defaults successfully!')),
                                );
                              }
                            },
                            child: const Text('Reset Database'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_forever_rounded, size: 18),
                  label: const Text('Reset Factory Defaults'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
