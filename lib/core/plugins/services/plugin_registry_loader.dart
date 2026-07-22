import 'package:monetra/core/plugins/domain/entities/plugin_manifest.dart';

class PluginRegistry {
  static final List<PluginManifest> _installedPlugins = [
    const PluginManifest(
      id: 'org.monetra.plugin.crypto',
      name: 'Crypto Asset Tracker',
      version: '1.0.0',
      author: 'Monetra Community',
      description: 'Track Bitcoin and Ethereum offline portfolio valuations',
      minMonetraVersion: '1.0.0',
      permissions: [
        PluginPermission.readAccounts,
        PluginPermission.dashboardAccess
      ],
      entryPoint: 'crypto_widget.dart',
      status: PluginStatus.enabled,
    ),
    const PluginManifest(
      id: 'org.monetra.plugin.csvexporter',
      name: 'Custom CSV Exporter',
      version: '1.2.0',
      author: 'Monetra Dev Team',
      description:
          'Export transaction ledger into custom EU tax reporting format',
      minMonetraVersion: '1.0.0',
      permissions: [
        PluginPermission.readTransactions,
        PluginPermission.exportFiles
      ],
      entryPoint: 'csv_exporter.dart',
      status: PluginStatus.enabled,
    ),
    const PluginManifest(
      id: 'org.monetra.plugin.darkglass',
      name: 'Dark Glass Theme Pack',
      version: '2.0.1',
      author: 'Design Studio',
      description: 'Glassmorphic sleek dark UI layout theme',
      minMonetraVersion: '1.0.0',
      permissions: [],
      entryPoint: 'dark_glass_theme.json',
      status: PluginStatus.disabled,
    ),
  ];

  static List<PluginManifest> getInstalledPlugins() =>
      List.unmodifiable(_installedPlugins);

  static bool hasPermission(
      PluginManifest plugin, PluginPermission permission) {
    return plugin.permissions.contains(permission);
  }
}
