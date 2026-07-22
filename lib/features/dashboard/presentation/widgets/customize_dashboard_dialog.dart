import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monetra/features/dashboard/domain/entities/dashboard_widget_config.dart';
import 'package:monetra/features/dashboard/presentation/providers/dashboard_providers.dart';

class CustomizeDashboardDialog extends ConsumerWidget {
  const CustomizeDashboardDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => const CustomizeDashboardDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final widgets = ref.watch(dashboardWidgetLayoutProvider);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Customize Workspace Dashboard',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Toggle widget visibility and drag to reorder cards.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 360,
              child: ReorderableListView(
                onReorder: (oldIndex, newIndex) {
                  var list = List.of(widgets);
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = list.removeAt(oldIndex);
                  list.insert(newIndex, item);

                  // Update sort order
                  final reordered = list
                      .asMap()
                      .entries
                      .map((e) => e.value.copyWith(sortOrder: e.key + 1))
                      .toList();
                  ref.read(dashboardWidgetLayoutProvider.notifier).state =
                      reordered;
                },
                children: [
                  for (final itemConfig in widgets)
                    CheckboxListTile(
                      key: Key(itemConfig.id),
                      value: itemConfig.isVisible,
                      title: Text(itemConfig.title,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      secondary: const Icon(Icons.drag_handle_rounded),
                      onChanged: (val) {
                        final updated =
                            widgets.map((DashboardWidgetConfig cfg) {
                          if (cfg.id == itemConfig.id) {
                            return cfg.copyWith(isVisible: val ?? true);
                          }
                          return cfg;
                        }).toList();
                        ref.read(dashboardWidgetLayoutProvider.notifier).state =
                            updated;
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Save Layout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
