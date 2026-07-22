import 'dart:async';
import 'package:uuid/uuid.dart';

import '../../domain/entities/transaction.dart';
import '../../domain/repositories/i_transaction_repository.dart';

class TransactionRepositoryImpl implements ITransactionRepository {
  final List<TransactionEntity> _transactions = [];
  final StreamController<List<TransactionEntity>> _streamController =
      StreamController<List<TransactionEntity>>.broadcast();

  TransactionRepositoryImpl([List<TransactionEntity>? initialTransactions]) {
    if (initialTransactions != null) {
      _transactions.addAll(initialTransactions);
    } else {
      _seedDefaultTransactions();
    }
    _emit();
  }

  void _seedDefaultTransactions() {
    final now = DateTime.now();
    _transactions.addAll([
      TransactionEntity(
        id: 'tx-101',
        accountId: 'acc-checking-1',
        categoryId: 'cat-salary',
        amount: 3850.00,
        type: TransactionType.income,
        date: now.subtract(const Duration(days: 2)),
        description: 'TechCorp Salary Deposit',
        notes: 'Monthly direct deposit',
        tags: const ['salary', 'income', 'work'],
        status: TransactionStatus.completed,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      TransactionEntity(
        id: 'tx-102',
        accountId: 'acc-checking-1',
        categoryId: 'cat-housing',
        amount: -1650.00,
        type: TransactionType.expense,
        date: now.subtract(const Duration(days: 3)),
        description: 'Apex Apartments Rent',
        notes: 'Monthly apartment rent payment',
        tags: const ['rent', 'essential'],
        status: TransactionStatus.completed,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      TransactionEntity(
        id: 'tx-103',
        accountId: 'acc-credit-1',
        categoryId: 'cat-groceries',
        amount: -142.80,
        type: TransactionType.expense,
        date: now.subtract(const Duration(days: 4)),
        description: 'Whole Foods Market',
        notes: 'Weekly fresh produce & essentials',
        tags: const ['groceries', 'food'],
        status: TransactionStatus.completed,
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(days: 4)),
      ),
      TransactionEntity(
        id: 'tx-104',
        accountId: 'acc-checking-1',
        destinationAccountId: 'acc-savings-1',
        categoryId: 'cat-transfer',
        amount: -500.00,
        type: TransactionType.transfer,
        date: now.subtract(const Duration(days: 6)),
        description: 'Transfer to Emergency Fund',
        notes: 'Automated savings goal allocation',
        tags: const ['savings', 'transfer'],
        status: TransactionStatus.completed,
        createdAt: now.subtract(const Duration(days: 6)),
        updatedAt: now.subtract(const Duration(days: 6)),
      ),
    ]);
  }

  void _emit() {
    final active = _transactions.where((t) => !t.isDeleted).toList();
    active.sort((a, b) => b.date.compareTo(a.date));
    _streamController.add(active);
  }

  @override
  Stream<List<TransactionEntity>> watchAllTransactions() =>
      _streamController.stream;

  @override
  Stream<List<TransactionEntity>> watchTransactionsByAccount(String accountId) {
    return _streamController.stream.map(
      (list) => list
          .where((t) =>
              t.accountId == accountId || t.destinationAccountId == accountId)
          .toList(),
    );
  }

  @override
  Future<List<TransactionEntity>> getTransactions({
    int limit = 100,
    int offset = 0,
    String? accountId,
    String? categoryId,
    String? merchantId,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    TransactionType? type,
    TransactionStatus? status,
    String? searchQuery,
  }) async {
    var filtered = _transactions.where((t) => !t.isDeleted).toList();

    if (accountId != null && accountId.isNotEmpty) {
      filtered = filtered
          .where((t) =>
              t.accountId == accountId || t.destinationAccountId == accountId)
          .toList();
    }
    if (categoryId != null && categoryId.isNotEmpty) {
      filtered = filtered.where((t) => t.categoryId == categoryId).toList();
    }
    if (merchantId != null && merchantId.isNotEmpty) {
      filtered = filtered.where((t) => t.merchantId == merchantId).toList();
    }
    if (type != null) {
      filtered = filtered.where((t) => t.type == type).toList();
    }
    if (status != null) {
      filtered = filtered.where((t) => t.status == status).toList();
    }
    if (startDate != null) {
      filtered = filtered
          .where((t) =>
              t.date.isAfter(startDate) || t.date.isAtSameMomentAs(startDate))
          .toList();
    }
    if (endDate != null) {
      filtered = filtered
          .where((t) =>
              t.date.isBefore(endDate) || t.date.isAtSameMomentAs(endDate))
          .toList();
    }
    if (minAmount != null) {
      filtered = filtered.where((t) => t.amount.abs() >= minAmount).toList();
    }
    if (maxAmount != null) {
      filtered = filtered.where((t) => t.amount.abs() <= maxAmount).toList();
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((t) {
        final inDesc = t.description.toLowerCase().contains(query);
        final inNotes = t.notes?.toLowerCase().contains(query) ?? false;
        final inTags = t.tags.any((tag) => tag.toLowerCase().contains(query));
        return inDesc || inNotes || inTags;
      }).toList();
    }

    filtered.sort((a, b) => b.date.compareTo(a.date));
    if (offset >= filtered.length) return [];
    final endIndex =
        (offset + limit < filtered.length) ? offset + limit : filtered.length;
    return filtered.sublist(offset, endIndex);
  }

  @override
  Future<TransactionEntity?> getTransactionById(String id) async {
    try {
      return _transactions.firstWhere((t) => t.id == id && !t.isDeleted);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> createTransaction(TransactionEntity transaction) async {
    _transactions.add(transaction);
    _emit();
  }

  @override
  Future<void> updateTransaction(TransactionEntity transaction) async {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction.copyWith(
        updatedAt: DateTime.now(),
        version: transaction.version + 1,
      );
      _emit();
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index != -1) {
      _transactions[index] = _transactions[index].copyWith(
        isDeleted: true,
        updatedAt: DateTime.now(),
      );
      _emit();
    }
  }

  @override
  Future<void> bulkDeleteTransactions(List<String> ids) async {
    for (final id in ids) {
      final index = _transactions.indexWhere((t) => t.id == id);
      if (index != -1) {
        _transactions[index] = _transactions[index]
            .copyWith(isDeleted: true, updatedAt: DateTime.now());
      }
    }
    _emit();
  }

  @override
  Future<void> bulkUpdateCategory(
      {required List<String> ids, required String categoryId}) async {
    for (final id in ids) {
      final index = _transactions.indexWhere((t) => t.id == id);
      if (index != -1) {
        _transactions[index] = _transactions[index]
            .copyWith(categoryId: categoryId, updatedAt: DateTime.now());
      }
    }
    _emit();
  }

  @override
  Future<void> createTransfer({
    required String sourceAccountId,
    required String destinationAccountId,
    required double amount,
    required DateTime date,
    required String description,
    String? notes,
  }) async {
    final now = DateTime.now();
    final transferTx = TransactionEntity(
      id: 'tx-transfer-${const Uuid().v4()}',
      accountId: sourceAccountId,
      destinationAccountId: destinationAccountId,
      categoryId: 'cat-transfer',
      amount: -amount.abs(),
      type: TransactionType.transfer,
      date: date,
      description: description,
      notes: notes,
      status: TransactionStatus.completed,
      createdAt: now,
      updatedAt: now,
    );
    await createTransaction(transferTx);
  }

  void dispose() {
    _streamController.close();
  }
}
