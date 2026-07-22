import 'package:flutter_test/flutter_test.dart';

import 'package:monetra/core/domain/entities/transaction.dart';
import 'package:monetra/features/import/domain/entities/import_payload.dart';
import 'package:monetra/features/import/services/duplicate_detector.dart';
import 'package:monetra/features/import/services/import_parsers.dart';

void main() {
  group('Monetra Import Engine & Data Ingestion Unit Tests', () {
    test('CsvFileParser extracts CSV headers and rows correctly', () {
      const csvStr =
          'Date,Amount,Description\n2026-07-22,-50.0,Supermarket\n2026-07-21,1200.0,Salary';

      final headers = CsvFileParser.extractHeaders(csvStr);
      expect(headers, equals(['Date', 'Amount', 'Description']));

      final rows = CsvFileParser.parseCsvRows(csvStr);
      expect(rows.length, equals(2));
      expect(rows.first['Amount'], equals('-50.0'));
      expect(rows.first['Description'], equals('Supermarket'));
    });

    test('JsonFileParser parses structured transaction JSON payload', () {
      final jsonStr = '''
      [
        {
          "id": "tx-json-1",
          "accountId": "acc-1",
          "amount": -25.0,
          "type": "expense",
          "date": "2026-07-22T00:00:00.000",
          "description": "Coffee Shop",
          "createdAt": "2026-07-22T00:00:00.000",
          "updatedAt": "2026-07-22T00:00:00.000"
        }
      ]
      ''';

      final list = JsonFileParser.parseJsonTransactions(jsonStr);
      expect(list.length, equals(1));
      expect(list.first.id, equals('tx-json-1'));
      expect(list.first.description, equals('Coffee Shop'));
      expect(list.first.amount, equals(-25.0));
    });

    test('DuplicateDetector identifies composite signature match correctly',
        () {
      final existingTx = TransactionEntity(
        id: 'tx-ex-1',
        accountId: 'acc-1',
        amount: -50.0,
        type: TransactionType.expense,
        date: DateTime(2026, 7, 22),
        description: 'Supermarket Groceries',
        createdAt: DateTime(2026, 7, 22),
        updatedAt: DateTime(2026, 7, 22),
      );

      final duplicateCandidate = TransactionEntity(
        id: 'tx-imp-99',
        accountId: 'acc-1',
        amount: -50.0,
        type: TransactionType.expense,
        date: DateTime(2026, 7, 22),
        description: 'Supermarket Groceries',
        createdAt: DateTime(2026, 7, 22),
        updatedAt: DateTime(2026, 7, 22),
      );

      final uniqueCandidate = TransactionEntity(
        id: 'tx-imp-100',
        accountId: 'acc-1',
        amount: -15.0,
        type: TransactionType.expense,
        date: DateTime(2026, 7, 22),
        description: 'Cinema Ticket',
        createdAt: DateTime(2026, 7, 22),
        updatedAt: DateTime(2026, 7, 22),
      );

      expect(
          DuplicateDetector.isDuplicate(
              candidate: duplicateCandidate,
              existingTransactions: [existingTx]),
          isTrue);
      expect(
          DuplicateDetector.isDuplicate(
              candidate: uniqueCandidate, existingTransactions: [existingTx]),
          isFalse);
    });

    test('ColumnMappingConfig copyWith updates field mappings cleanly', () {
      const config = ColumnMappingConfig();
      final updated =
          config.copyWith(dateColumn: 'TxDate', amountColumn: 'TxAmount');

      expect(updated.dateColumn, equals('TxDate'));
      expect(updated.amountColumn, equals('TxAmount'));
      expect(updated.descriptionColumn, equals('Description'));
    });
  });
}
