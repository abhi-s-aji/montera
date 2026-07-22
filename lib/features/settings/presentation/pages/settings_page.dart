import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/entities/app_settings.dart';
import '../../../../core/providers/account_providers.dart';
import '../../../../core/providers/category_providers.dart';
import '../../../../core/providers/settings_providers.dart';
import '../../../../core/providers/transaction_providers.dart';
import '../../../../core/theme/monetra_colors.dart';
import '../../../../core/widgets/monetra_card.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

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
    final settings = ref.watch(settingsNotifierProvider);
    final settingsNotifier = ref.read(settingsNotifierProvider.notifier);
    final searchQuery = ref.watch(settingsSearchQueryProvider);

    final isMobile = MediaQuery.of(context).size.width < 600;

    final accentColors = [
      '#6366F1',
      '#10B981',
      '#EC4899',
      '#F59E0B',
      '#06B6D4',
      '#8B5CF6'
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) ...[
            Text(
              'Workspace Customization & Privacy',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tailor Monetra to your aesthetic preferences',
              style: TextStyle(
                fontSize: 13,
                color: theme.textTheme.bodyMedium?.color
                    ?.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                await settingsNotifier.resetToDefaults();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Settings reset to factory defaults')),
                  );
                }
              },
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Reset Defaults'),
            ),
          ] else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Workspace Customization & Privacy',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tailor Monetra to your aesthetic preferences and control your data.',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textTheme.bodyMedium?.color
                            ?.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    await settingsNotifier.resetToDefaults();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Settings reset to factory defaults')),
                      );
                    }
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Reset Defaults'),
                ),
              ],
            ),
          const SizedBox(height: 20),
          // Search Input
          TextField(
            onChanged: (val) =>
                ref.read(settingsSearchQueryProvider.notifier).state = val,
            decoration: InputDecoration(
              hintText:
                  'Search settings options (theme, accent, currency...)...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => ref
                          .read(settingsSearchQueryProvider.notifier)
                          .state = '',
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          // Privacy Card
          MonetraCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: MonetraColors.incomeGreen.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shield_outlined,
                      color: MonetraColors.incomeGreen, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '100% Offline & Private',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Zero trackers. Zero remote servers. All your financial records remain exclusively on this device.',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Theme & Appearance Card
          MonetraCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Theme & Appearance',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                          onSelected: (_) =>
                              settingsNotifier.updateThemeMode(AppThemeMode.dark),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('OLED')),
                          selected: settings.themeMode == AppThemeMode.oled,
                          onSelected: (_) =>
                              settingsNotifier.updateThemeMode(AppThemeMode.oled),
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
          const SizedBox(height: 20),
          // Developer & Diagnostics Section
          MonetraCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Developer & Advanced Mode',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Enable Developer Mode'),
                  subtitle: const Text(
                      'Expose internal diagnostics, SQLite version info, and test logs'),
                  value: settings.isDeveloperMode,
                  onChanged: (val) => settingsNotifier.toggleDeveloperMode(val),
                ),
                if (settings.isDeveloperMode) ...[
                  const Divider(),
                  const Text('Diagnostics info:',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Engine: Drift SQLite (WAL Mode)',
                      style: TextStyle(fontSize: 11, fontFamily: 'monospace')),
                  const Text('State Engine: Flutter Riverpod 2.6.1',
                      style: TextStyle(fontSize: 11, fontFamily: 'monospace')),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Data Portability Section
          MonetraCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Data Portability & Ownership',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
