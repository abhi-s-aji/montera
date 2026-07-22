import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:monetra/features/search/presentation/providers/search_providers.dart';

class CommandPaletteOverlay extends ConsumerStatefulWidget {
  const CommandPaletteOverlay({super.key});

  @override
  ConsumerState<CommandPaletteOverlay> createState() =>
      _CommandPaletteOverlayState();
}

class _CommandPaletteOverlayState extends ConsumerState<CommandPaletteOverlay> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(searchResultsListProvider);
    final commands = ref.watch(availableCommandsProvider);

    final displayItems = _searchController.text.trim().isEmpty
        ? commands.map((c) => c.label).toList()
        : results.map((r) => r.title).toList();

    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: const EdgeInsets.only(top: 80, left: 16, right: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 450),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText:
                      'Type a command or search everywhere... (e.g. Transaction, Rent)',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(globalSearchQueryProvider.notifier).state = '';
                    },
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (val) {
                  ref.read(globalSearchQueryProvider.notifier).state = val;
                },
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Expanded(
                child: displayItems.isEmpty
                    ? const Center(
                        child: Text('No matching results or commands found.'))
                    : ListView.builder(
                        itemCount: _searchController.text.trim().isEmpty
                            ? commands.length
                            : results.length,
                        itemBuilder: (ctx, idx) {
                          if (_searchController.text.trim().isEmpty) {
                            final cmd = commands[idx];
                            return ListTile(
                              dense: true,
                              leading:
                                  const Icon(Icons.terminal_rounded, size: 18),
                              title: Text(cmd.label,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              subtitle: Text(cmd.description),
                              trailing: Chip(
                                label: Text(cmd.shortcut,
                                    style: const TextStyle(fontSize: 10)),
                                visualDensity: VisualDensity.compact,
                              ),
                              onTap: () {
                                Navigator.of(ctx).pop();
                                context.go(cmd.targetRoute);
                              },
                            );
                          } else {
                            final res = results[idx];
                            return ListTile(
                              dense: true,
                              leading: Icon(
                                res.type.name == 'transaction'
                                    ? Icons.receipt_rounded
                                    : res.type.name == 'command'
                                        ? Icons.terminal_rounded
                                        : Icons.layers_rounded,
                                size: 18,
                              ),
                              title: Text(res.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              subtitle: Text(res.subtitle),
                              onTap: () {
                                Navigator.of(ctx).pop();
                                context.go(res.targetRoute);
                              },
                            );
                          }
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
