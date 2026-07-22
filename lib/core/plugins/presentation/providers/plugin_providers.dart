import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monetra/core/plugins/domain/entities/plugin_manifest.dart';
import 'package:monetra/core/plugins/services/plugin_registry_loader.dart';

final installedPluginsListProvider = StateProvider<List<PluginManifest>>((ref) {
  return PluginRegistry.getInstalledPlugins();
});

final enabledPluginsListProvider = Provider<List<PluginManifest>>((ref) {
  final plugins = ref.watch(installedPluginsListProvider);
  return plugins.where((p) => p.status == PluginStatus.enabled).toList();
});
