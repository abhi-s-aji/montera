import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monetra/core/providers/repository_providers.dart';
import 'package:monetra/core/widgets/monetra_card.dart';
import 'package:monetra/features/import/domain/entities/import_payload.dart';
import 'package:monetra/features/import/presentation/providers/import_providers.dart';

class ImportPage extends ConsumerStatefulWidget {
  const ImportPage({super.key});

  @override
  ConsumerState<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends ConsumerState<ImportPage> {
  final TextEditingController _rawContentController = TextEditingController();

  @override
  void dispose() {
    _rawContentController.dispose();
    super.dispose();
  }

  void _executeImport(BuildContext context) {
    final candidates = ref.read(importPreviewCandidatesProvider);
    final strategy = ref.read(importDuplicateStrategyProvider);
    final repo = ref.read(transactionRepositoryProvider);

    final stopwatch = Stopwatch()..start();
    int imported = 0;
    int skipped = 0;
    int failed = 0;

    for (final candidate in candidates) {
      if (candidate.isDuplicate && strategy == ImportDuplicateStrategy.skip) {
        skipped++;
        continue;
      }
      try {
        repo.createTransaction(candidate.transaction);
        imported++;
      } catch (_) {
        failed++;
      }
    }

    stopwatch.stop();

    final report = ImportReport(
      totalParsedRecords: candidates.length,
      successfullyImportedRecords: imported,
      skippedDuplicates: skipped,
      failedRecords: failed,
      elapsedTimeMs: stopwatch.elapsedMilliseconds.toDouble(),
    );

    ref.read(importReportResultProvider.notifier).state = report;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.green),
            SizedBox(width: 8),
            Text('Import Complete'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Total Parsed Records: ${report.totalParsedRecords}'),
            Text(
                '• Successfully Imported: ${report.successfullyImportedRecords}'),
            Text('• Skipped Duplicates: ${report.skippedDuplicates}'),
            Text('• Failed Records: ${report.failedRecords}'),
            const SizedBox(height: 8),
            Text('Elapsed Time: ${report.elapsedTimeMs.toStringAsFixed(1)} ms',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentStep = ref.watch(currentImportStepProvider);
    final fileType = ref.watch(selectedImportFileTypeProvider);
    final headers = ref.watch(detectedCsvHeadersProvider);
    final mapping = ref.watch(columnMappingConfigProvider);
    final candidates = ref.watch(importPreviewCandidatesProvider);
    final strategy = ref.watch(importDuplicateStrategyProvider);

    final isMobile = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) ...[
            Text(
              'Import Engine & Data Ingestion Studio',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Offline-first wizard for financial records',
              style: TextStyle(
                fontSize: 13,
                color:
                    theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
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
                      'Import Engine & Data Ingestion Studio',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Offline-first wizard for CSV, JSON, and Monetra Backup financial records',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textTheme.bodyMedium?.color
                            ?.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          const SizedBox(height: 24),

          // Wizard Stepper Controls
          Row(
            children: [
              _buildStepIndicator(context, 1, 'Select File', currentStep >= 1),
              const Expanded(child: Divider()),
              _buildStepIndicator(context, 2, 'Map Columns', currentStep >= 2),
              const Expanded(child: Divider()),
              _buildStepIndicator(
                  context, 3, 'Preview & Resolve', currentStep >= 3),
            ],
          ),
          const SizedBox(height: 24),

          // Step 1: File Selection & Raw Content Input
          if (currentStep == 1)
            MonetraCard(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Step 1: Select Format & Input Raw Content',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('CSV Format'),
                        selected: fileType == ImportFileType.csv,
                        onSelected: (_) => ref
                            .read(selectedImportFileTypeProvider.notifier)
                            .state = ImportFileType.csv,
                      ),
                      const SizedBox(width: 12),
                      ChoiceChip(
                        label: const Text('JSON Format'),
                        selected: fileType == ImportFileType.json,
                        onSelected: (_) => ref
                            .read(selectedImportFileTypeProvider.notifier)
                            .state = ImportFileType.json,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _rawContentController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: fileType == ImportFileType.csv
                          ? 'Paste CSV content here...\nExample:\nDate,Amount,Description\n2026-07-22,-45.50,Supermarket'
                          : 'Paste JSON array payload here...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (val) =>
                        ref.read(rawImportContentProvider.notifier).state = val,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(currentImportStepProvider.notifier).state = 2,
                    child: const Text('Next: Map Columns'),
                  ),
                ],
              ),
            ),

          // Step 2: Column Mapping Configuration
          if (currentStep == 2)
            MonetraCard(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Step 2: Configure Column Mapping',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color)),
                  const SizedBox(height: 8),
                  Text(
                      'Detected Headers: ${headers.isEmpty ? "None" : headers.join(", ")}',
                      style: TextStyle(
                          fontSize: 13,
                          color: theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.6))),
                  const SizedBox(height: 16),
                  _buildDropdownRow('Date Column', mapping.dateColumn, headers,
                      (val) {
                    if (val != null)
                      ref.read(columnMappingConfigProvider.notifier).state =
                          mapping.copyWith(dateColumn: val);
                  }),
                  _buildDropdownRow(
                      'Amount Column', mapping.amountColumn, headers, (val) {
                    if (val != null)
                      ref.read(columnMappingConfigProvider.notifier).state =
                          mapping.copyWith(amountColumn: val);
                  }),
                  _buildDropdownRow(
                      'Description Column', mapping.descriptionColumn, headers,
                      (val) {
                    if (val != null)
                      ref.read(columnMappingConfigProvider.notifier).state =
                          mapping.copyWith(descriptionColumn: val);
                  }),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () => ref
                            .read(currentImportStepProvider.notifier)
                            .state = 1,
                        child: const Text('Back'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => ref
                            .read(currentImportStepProvider.notifier)
                            .state = 3,
                        child: const Text('Next: Preview & Duplicates'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Step 3: Preview Candidates & Execute Import
          if (currentStep == 3)
            MonetraCard(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Step 3: Preview Transactions & Resolution Strategy',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color)),
                  const SizedBox(height: 12),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      const Text('Duplicate Strategy: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      ChoiceChip(
                        label: const Text('Skip Duplicates'),
                        selected: strategy == ImportDuplicateStrategy.skip,
                        onSelected: (_) => ref
                            .read(importDuplicateStrategyProvider.notifier)
                            .state = ImportDuplicateStrategy.skip,
                      ),
                      ChoiceChip(
                        label: const Text('Import All (Create New)'),
                        selected: strategy == ImportDuplicateStrategy.createNew,
                        onSelected: (_) => ref
                            .read(importDuplicateStrategyProvider.notifier)
                            .state = ImportDuplicateStrategy.createNew,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Candidate Count: ${candidates.length} records parsed',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: candidates.length,
                        itemBuilder: (ctx, idx) {
                          final cand = candidates[idx];
                          return ListTile(
                            dense: true,
                            leading: Icon(
                              cand.isDuplicate
                                  ? Icons.warning_amber_rounded
                                  : Icons.check_circle_outline_rounded,
                              color: cand.isDuplicate
                                  ? Colors.orange
                                  : Colors.green,
                            ),
                            title: Text(cand.transaction.description),
                            subtitle: Text(
                                'Date: ${cand.transaction.date.toIso8601String().split('T').first} | Amount: ${cand.transaction.amount}'),
                            trailing: cand.isDuplicate
                                ? const Chip(
                                    label: Text('Duplicate',
                                        style: TextStyle(fontSize: 10)),
                                    backgroundColor: Colors.orangeAccent)
                                : null,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () => ref
                            .read(currentImportStepProvider.notifier)
                            .state = 2,
                        child: const Text('Back'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: candidates.isEmpty
                            ? null
                            : () => _executeImport(context),
                        icon: const Icon(Icons.file_upload_rounded, size: 18),
                        label: const Text('Execute Data Import'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(
      BuildContext context, int step, String title, bool isActive) {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor:
              isActive ? Theme.of(context).primaryColor : Colors.grey.shade400,
          child: Text('$step',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 6),
        Text(title,
            style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: 13)),
      ],
    );
  }

  Widget _buildDropdownRow(String label, String value, List<String> options,
      ValueChanged<String?> onChanged) {
    final effectiveOptions =
        options.contains(value) ? options : [value, ...options];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          DropdownButton<String>(
            value: value,
            items: effectiveOptions
                .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
