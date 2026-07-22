import 'dart:convert';
import 'package:monetra/core/domain/entities/transaction.dart';

class CsvFileParser {
  static List<String> extractHeaders(String csvContent) {
    if (csvContent.trim().isEmpty) return [];
    final lines = LineSplitter.split(csvContent).toList();
    if (lines.isEmpty) return [];
    final firstLine = lines.first;
    return firstLine
        .split(',')
        .map((h) => h.trim().replaceAll('"', ''))
        .toList();
  }

  static List<Map<String, String>> parseCsvRows(String csvContent) {
    final lines = LineSplitter.split(csvContent).toList();
    if (lines.length < 2) return [];

    final headers = lines.first
        .split(',')
        .map((h) => h.trim().replaceAll('"', ''))
        .toList();
    final List<Map<String, String>> rows = [];

    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      final values =
          line.split(',').map((v) => v.trim().replaceAll('"', '')).toList();

      final Map<String, String> rowMap = {};
      for (int j = 0; j < headers.length && j < values.length; j++) {
        rowMap[headers[j]] = values[j];
      }
      rows.add(rowMap);
    }
    return rows;
  }
}

class JsonFileParser {
  static List<TransactionEntity> parseJsonTransactions(String jsonContent) {
    try {
      final List dynamicList = jsonDecode(jsonContent) as List;
      return dynamicList
          .map((item) =>
              TransactionEntity.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
