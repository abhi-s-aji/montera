import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/domain/entities/transaction.dart';
import '../../../../core/providers/account_providers.dart';
import '../../../../core/providers/category_providers.dart';
import '../../../../core/providers/repository_providers.dart';

class TransactionEditorDialog extends ConsumerStatefulWidget {
  final TransactionEntity? initialTransaction;

  const TransactionEditorDialog({super.key, this.initialTransaction});

  static Future<void> show(BuildContext context,
      {TransactionEntity? transaction}) {
    return showDialog(
      context: context,
      builder: (ctx) =>
          TransactionEditorDialog(initialTransaction: transaction),
    );
  }

  @override
  ConsumerState<TransactionEditorDialog> createState() =>
      _TransactionEditorDialogState();
}

class _TransactionEditorDialogState
    extends ConsumerState<TransactionEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  late TextEditingController _tagsController;

  String? _selectedAccountId;
  String? _selectedDestAccountId;
  String? _selectedCategoryId;
  TransactionType _selectedType = TransactionType.expense;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final tx = widget.initialTransaction;
    _descController = TextEditingController(text: tx?.description ?? '');
    _amountController = TextEditingController(
        text: tx != null ? tx.amount.abs().toString() : '');
    _notesController = TextEditingController(text: tx?.notes ?? '');
    _tagsController =
        TextEditingController(text: tx != null ? tx.tags.join(', ') : '');

    if (tx != null) {
      _selectedAccountId = tx.accountId;
      _selectedDestAccountId = tx.destinationAccountId;
      _selectedCategoryId = tx.categoryId;
      _selectedType = tx.type;
      _selectedDate = tx.date;
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an account')),
      );
      return;
    }

    final rawAmount = double.parse(_amountController.text);
    final amount =
        _selectedType == TransactionType.expense ? -rawAmount : rawAmount;
    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final now = DateTime.now();
    final txRepo = ref.read(transactionRepositoryProvider);

    if (widget.initialTransaction == null) {
      final newTx = TransactionEntity(
        id: 'tx-${const Uuid().v4()}',
        accountId: _selectedAccountId!,
        destinationAccountId: _selectedType == TransactionType.transfer
            ? _selectedDestAccountId
            : null,
        categoryId: _selectedCategoryId,
        amount: amount,
        type: _selectedType,
        date: _selectedDate,
        description: _descController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        tags: tags,
        status: TransactionStatus.completed,
        createdAt: now,
        updatedAt: now,
      );
      await txRepo.createTransaction(newTx);
    } else {
      final updatedTx = widget.initialTransaction!.copyWith(
        accountId: _selectedAccountId!,
        destinationAccountId: _selectedType == TransactionType.transfer
            ? _selectedDestAccountId
            : null,
        categoryId: _selectedCategoryId,
        amount: amount,
        type: _selectedType,
        date: _selectedDate,
        description: _descController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        tags: tags,
        updatedAt: now,
      );
      await txRepo.updateTransaction(updatedTx);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsStreamProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.initialTransaction == null
                          ? 'New Transaction'
                          : 'Edit Transaction',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Expense')),
                        selected: _selectedType == TransactionType.expense,
                        onSelected: (_) => setState(
                            () => _selectedType = TransactionType.expense),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Income')),
                        selected: _selectedType == TransactionType.income,
                        onSelected: (_) => setState(
                            () => _selectedType = TransactionType.income),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Transfer')),
                        selected: _selectedType == TransactionType.transfer,
                        onSelected: (_) => setState(
                            () => _selectedType = TransactionType.transfer),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'e.g. Whole Foods Groceries',
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '\$ ',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (double.tryParse(v) == null) return 'Enter valid number';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                accountsAsync.when(
                  data: (accounts) {
                    if (_selectedAccountId == null && accounts.isNotEmpty) {
                      _selectedAccountId = accounts.first.id;
                    }
                    return DropdownButtonFormField<String>(
                      initialValue: _selectedAccountId,
                      decoration: InputDecoration(
                          labelText: _selectedType == TransactionType.transfer
                              ? 'Source Account'
                              : 'Account'),
                      items: accounts
                          .map((a) => DropdownMenuItem(
                                value: a.id,
                                child: Text(a.name),
                              ))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedAccountId = val),
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const SizedBox(),
                ),
                if (_selectedType == TransactionType.transfer) ...[
                  const SizedBox(height: 12),
                  accountsAsync.when(
                    data: (accounts) {
                      final destOptions = accounts
                          .where((a) => a.id != _selectedAccountId)
                          .toList();
                      return DropdownButtonFormField<String>(
                        initialValue: _selectedDestAccountId,
                        decoration: const InputDecoration(
                            labelText: 'Destination Account'),
                        items: destOptions
                            .map((a) => DropdownMenuItem(
                                  value: a.id,
                                  child: Text(a.name),
                                ))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedDestAccountId = val),
                      );
                    },
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                  ),
                ],
                const SizedBox(height: 12),
                categoriesAsync.when(
                  data: (categories) {
                    return DropdownButtonFormField<String>(
                      initialValue: _selectedCategoryId,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: categories
                          .map((c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name),
                              ))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedCategoryId = val),
                    );
                  },
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags (comma separated)',
                    hintText: 'groceries, food, essential',
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: Text(widget.initialTransaction == null
                        ? 'Create Transaction'
                        : 'Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
