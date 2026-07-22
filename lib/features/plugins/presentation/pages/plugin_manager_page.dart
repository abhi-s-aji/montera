import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monetra/core/plugins/domain/entities/plugin_manifest.dart';
import 'package:monetra/core/plugins/presentation/providers/plugin_providers.dart';
import 'package:monetra/core/widgets/monetra_card.dart';

class PluginManagerPage extends ConsumerWidget {
  const PluginManagerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final plugins = ref.watch(installedPluginsListProvider);

    final isMobile = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plugin SDK & Extension Framework Studio',
            style: TextStyle(
              fontSize: isMobile ? 20 : 26,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Offline sandboxed extension plugins, manifest validation, and granted permissions',
            style: TextStyle(
              fontSize: isMobile ? 13 : 14,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),

          // Installed Plugins List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: plugins.length,
            itemBuilder: (ctx, idx) {
              final p = plugins[idx];
              final isEnabled = p.status == PluginStatus.enabled;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: MonetraCard(
                  padding: EdgeInsets.all(isMobile ? 16.0 : 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: theme.colorScheme.primary
                                .withValues(alpha: 0.1),
                            child: Icon(Icons.extension_rounded,
                                color: theme.colorScheme.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    Text(
                                      p.name,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Chip(
                                      label: Text('v${p.version}',
                                          style: const TextStyle(fontSize: 10)),
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Author: ${p.author} | Entry: ${p.entryPoint}',
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.grey),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: isEnabled,
                            onChanged: (val) {
                              final updatedList = plugins.map((item) {
                                if (item.id == p.id) {
                                  return item.copyWith(
                                      status: val
                                          ? PluginStatus.enabled
                                          : PluginStatus.disabled);
                                }
                                return item;
                              }).toList();
                              ref
                                  .read(installedPluginsListProvider.notifier)
                                  .state = updatedList;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(p.description,
                          style: TextStyle(
                              fontSize: 13,
                              color: theme.textTheme.bodyMedium?.color)),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),

                      // Granted Permissions Chips
                      if (isMobile) ...[
                        const Text('Granted Permissions:',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        p.permissions.isEmpty
                            ? const Text('None (Sandboxed UI Pack)',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey))
                            : Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: p.permissions
                                    .map((perm) => Chip(
                                          avatar: const Icon(
                                              Icons.lock_open_rounded,
                                              size: 12,
                                              color: Colors.green),
                                          label: Text(perm.name,
                                              style: const TextStyle(
                                                  fontSize: 10)),
                                          visualDensity: VisualDensity.compact,
                                        ))
                                    .toList(),
                              ),
                      ] else
                        Row(
                          children: [
                            const Text('Granted Permissions: ',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: p.permissions.isEmpty
                                  ? const Text('None (Sandboxed UI Pack)',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey))
                                  : Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: p.permissions
                                          .map((perm) => Chip(
                                                avatar: const Icon(
                                                    Icons.lock_open_rounded,
                                                    size: 12,
                                                    color: Colors.green),
                                                label: Text(perm.name,
                                                    style: const TextStyle(
                                                        fontSize: 10)),
                                                visualDensity:
                                                    VisualDensity.compact,
                                              ))
                                          .toList(),
                                    ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
