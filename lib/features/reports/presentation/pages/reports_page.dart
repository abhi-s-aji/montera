import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/monetra_card.dart';
import '../../domain/entities/report_config.dart';
import '../providers/reports_providers.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedFormat = ref.watch(selectedReportFormatProvider);
    final selectedType = ref.watch(selectedReportTypeProvider);
    final exportContent = ref.watch(generatedExportContentProvider);

    final isMobile = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Reports & Export Studio',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: exportContent));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              '${selectedFormat.name.toUpperCase()} report copied to clipboard!')),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('Copy'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Generate reports offline',
              style: TextStyle(
                fontSize: 13,
                color: theme.textTheme.bodyMedium?.color
                    ?.withValues(alpha: 0.6),
              ),
            ),
          ] else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reports & Export Studio',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Generate Markdown, CSV, JSON, and HTML reports offline',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textTheme.bodyMedium?.color
                            ?.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: exportContent));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              '${selectedFormat.name.toUpperCase()} report copied to clipboard!')),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('Copy Export'),
                ),
              ],
            ),
          const SizedBox(height: 20),
          // Configuration Controls
          if (isMobile) ...[
            DropdownButtonFormField<ReportType>(
              initialValue: selectedType,
              decoration:
                  const InputDecoration(labelText: 'Report Statement Type'),
              items: ReportType.values
                  .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.name.toUpperCase()),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  ref.read(selectedReportTypeProvider.notifier).state = val;
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ExportFormat>(
              initialValue: selectedFormat,
              decoration:
                  const InputDecoration(labelText: 'Export Output Format'),
              items: ExportFormat.values
                  .map((f) => DropdownMenuItem(
                        value: f,
                        child: Text(f.name.toUpperCase()),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  ref.read(selectedReportFormatProvider.notifier).state = val;
                }
              },
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<ReportType>(
                    initialValue: selectedType,
                    decoration:
                        const InputDecoration(labelText: 'Report Statement Type'),
                    items: ReportType.values
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(t.name.toUpperCase()),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(selectedReportTypeProvider.notifier).state = val;
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<ExportFormat>(
                    initialValue: selectedFormat,
                    decoration:
                        const InputDecoration(labelText: 'Export Output Format'),
                    items: ExportFormat.values
                        .map((f) => DropdownMenuItem(
                              value: f,
                              child: Text(f.name.toUpperCase()),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(selectedReportFormatProvider.notifier).state =
                            val;
                      }
                    },
                  ),
                ),
              ],
            ),
          const SizedBox(height: 24),
          // Report Code/Text Preview MonetraCard
          MonetraCard(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Generated Report Output (${selectedFormat.name.toUpperCase()})',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color),
                    ),
                    Text(
                      '${exportContent.length} bytes',
                      style: TextStyle(
                          fontSize: 12,
                          color: theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.3)),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SelectableText(
                      exportContent,
                      style: const TextStyle(
                          fontFamily: 'monospace', fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
