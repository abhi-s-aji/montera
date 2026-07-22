import 'package:equatable/equatable.dart';
import 'package:monetra/core/domain/entities/transaction.dart';

enum ImportFileType { csv, json, monetraBackup }

class ImportRawFile extends Equatable {
  final String fileName;
  final ImportFileType fileType;
  final String rawContent;
  final int sizeBytes;

  const ImportRawFile({
    required this.fileName,
    required this.fileType,
    required this.rawContent,
    required this.sizeBytes,
  });

  @override
  List<Object?> get props => [fileName, fileType, rawContent, sizeBytes];
}

class ColumnMappingConfig extends Equatable {
  final String dateColumn;
  final String amountColumn;
  final String descriptionColumn;
  final String? categoryColumn;
  final String? accountColumn;
  final String? notesColumn;
  final String? tagsColumn;
  final String? currencyColumn;

  const ColumnMappingConfig({
    this.dateColumn = 'Date',
    this.amountColumn = 'Amount',
    this.descriptionColumn = 'Description',
    this.categoryColumn = 'Category',
    this.accountColumn = 'Account',
    this.notesColumn = 'Notes',
    this.tagsColumn = 'Tags',
    this.currencyColumn = 'Currency',
  });

  ColumnMappingConfig copyWith({
    String? dateColumn,
    String? amountColumn,
    String? descriptionColumn,
    String? categoryColumn,
    String? accountColumn,
    String? notesColumn,
    String? tagsColumn,
    String? currencyColumn,
  }) {
    return ColumnMappingConfig(
      dateColumn: dateColumn ?? this.dateColumn,
      amountColumn: amountColumn ?? this.amountColumn,
      descriptionColumn: descriptionColumn ?? this.descriptionColumn,
      categoryColumn: categoryColumn ?? this.categoryColumn,
      accountColumn: accountColumn ?? this.accountColumn,
      notesColumn: notesColumn ?? this.notesColumn,
      tagsColumn: tagsColumn ?? this.tagsColumn,
      currencyColumn: currencyColumn ?? this.currencyColumn,
    );
  }

  @override
  List<Object?> get props => [
        dateColumn,
        amountColumn,
        descriptionColumn,
        categoryColumn,
        accountColumn,
        notesColumn,
        tagsColumn,
        currencyColumn,
      ];
}

class ImportPreviewCandidate extends Equatable {
  final TransactionEntity transaction;
  final bool isDuplicate;
  final String? duplicateReason;
  final bool isValid;
  final String? validationWarning;

  const ImportPreviewCandidate({
    required this.transaction,
    this.isDuplicate = false,
    this.duplicateReason,
    this.isValid = true,
    this.validationWarning,
  });

  @override
  List<Object?> get props => [
        transaction,
        isDuplicate,
        duplicateReason,
        isValid,
        validationWarning,
      ];
}

enum ImportDuplicateStrategy { skip, replace, createNew }

class ImportReport extends Equatable {
  final int totalParsedRecords;
  final int successfullyImportedRecords;
  final int skippedDuplicates;
  final int failedRecords;
  final double elapsedTimeMs;

  const ImportReport({
    required this.totalParsedRecords,
    required this.successfullyImportedRecords,
    required this.skippedDuplicates,
    required this.failedRecords,
    required this.elapsedTimeMs,
  });

  @override
  List<Object?> get props => [
        totalParsedRecords,
        successfullyImportedRecords,
        skippedDuplicates,
        failedRecords,
        elapsedTimeMs,
      ];
}
