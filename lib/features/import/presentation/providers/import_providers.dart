import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monetra/core/domain/entities/transaction.dart';
import 'package:monetra/core/providers/transaction_providers.dart';
import 'package:monetra/features/import/domain/entities/import_payload.dart';
import 'package:monetra/features/import/services/duplicate_detector.dart';
import 'package:monetra/features/import/services/import_parsers.dart';

final currentImportStepProvider = StateProvider<int>((ref) => 1);

final selectedImportFileTypeProvider =
    StateProvider<ImportFileType>((ref) => ImportFileType.csv);

final rawImportContentProvider = StateProvider<String>((ref) => '');

final columnMappingConfigProvider =
    StateProvider<ColumnMappingConfig>((ref) => const ColumnMappingConfig());

final importDuplicateStrategyProvider = StateProvider<ImportDuplicateStrategy>(
    (ref) => ImportDuplicateStrategy.skip);

final detectedCsvHeadersProvider = Provider<List<String>>((ref) {
  final content = ref.watch(rawImportContentProvider);
  return CsvFileParser.extractHeaders(content);
});

final importPreviewCandidatesProvider =
    Provider<List<ImportPreviewCandidate>>((ref) {
  final content = ref.watch(rawImportContentProvider);
  final type = ref.watch(selectedImportFileTypeProvider);
  final mapping = ref.watch(columnMappingConfigProvider);
  final existingTransactions =
      ref.watch(transactionsStreamProvider).value ?? [];

  if (content.trim().isEmpty) return [];

  List<TransactionEntity> rawList = [];

  if (type == ImportFileType.csv) {
    final rows = CsvFileParser.parseCsvRows(content);
    rawList = rows.map((row) {
      final dateStr =
          row[mapping.dateColumn] ?? DateTime.now().toIso8601String();
      final date = DateTime.tryParse(dateStr) ?? DateTime.now();
      final amount = double.tryParse(row[mapping.amountColumn] ?? '0') ?? 0.0;
      final desc = row[mapping.descriptionColumn] ?? 'Imported Transaction';

      return TransactionEntity(
        id: 'imp-tx-${DateTime.now().microsecondsSinceEpoch}-${row.hashCode}',
        accountId: 'acc-default',
        amount: amount,
        type: amount < 0 ? TransactionType.expense : TransactionType.income,
        date: date,
        description: desc,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }).toList();
  } else if (type == ImportFileType.json) {
    rawList = JsonFileParser.parseJsonTransactions(content);
  }

  return rawList.map((tx) {
    final isDup = DuplicateDetector.isDuplicate(
        candidate: tx, existingTransactions: existingTransactions);
    return ImportPreviewCandidate(
      transaction: tx,
      isDuplicate: isDup,
      duplicateReason:
          isDup ? 'Composite Match (Date, Amount, Description)' : null,
    );
  }).toList();
});

final importReportResultProvider = StateProvider<ImportReport?>((ref) => null);
