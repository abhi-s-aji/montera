import 'package:flutter_test/flutter_test.dart';

import 'package:monetra/core/plugins/domain/entities/plugin_manifest.dart';
import 'package:monetra/core/plugins/services/plugin_registry_loader.dart';

void main() {
  group('Monetra Plugin SDK & Extension Framework Unit Tests', () {
    test('PluginManifest copyWith updates status and properties correctly', () {
      const manifest = PluginManifest(
        id: 'org.monetra.plugin.test',
        name: 'Test Plugin',
        version: '1.0.0',
        author: 'Tester',
        description: 'Test description',
        minMonetraVersion: '1.0.0',
        permissions: [PluginPermission.readAccounts],
        entryPoint: 'main.dart',
      );

      final updated = manifest.copyWith(status: PluginStatus.enabled);
      expect(updated.status, equals(PluginStatus.enabled));
      expect(updated.id, equals('org.monetra.plugin.test'));
    });

    test(
        'PluginRegistry provides installed sample plugins and verifies permissions',
        () {
      final plugins = PluginRegistry.getInstalledPlugins();
      expect(plugins.length, greaterThanOrEqualTo(3));

      final cryptoPlugin =
          plugins.firstWhere((p) => p.id == 'org.monetra.plugin.crypto');
      expect(
          PluginRegistry.hasPermission(
              cryptoPlugin, PluginPermission.readAccounts),
          isTrue);
      expect(
          PluginRegistry.hasPermission(
              cryptoPlugin, PluginPermission.writeTransactions),
          isFalse);
    });
  });
}
