import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/domain/entities/budget.dart';
import '../../../../core/providers/category_providers.dart';
import '../../../../core/providers/repository_providers.dart';

class BudgetEditorDialog extends ConsumerStatefulWidget {
  final Budget? initialBudget;

  const BudgetEditorDialog({super.key, this.initialBudget});

  static Future<void> show(BuildContext context, {Budget? budget}) {
    return showDialog(
      context: context,
      builder: (ctx) => BudgetEditorDialog(initialBudget: budget),
    );
  }

  @override
  ConsumerState<BudgetEditorDialog> createState() => _BudgetEditorDialogState();
}

class _BudgetEditorDialogState extends ConsumerState<BudgetEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _amountController;

  String? _selectedCategoryId;
  BudgetPeriod _selectedPeriod = BudgetPeriod.monthly;

  @override
  void initState() {
    super.initState();
    final b = widget.initialBudget;
    _nameController = TextEditingController(text: b?.name ?? '');
    _descController = TextEditingController(text: b?.description ?? '');
    _amountController =
        TextEditingController(text: b != null ? b.amount.toString() : '');

    if (b != null) {
      _selectedCategoryId = b.categoryId;
      _selectedPeriod = b.period;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a target category')),
      );
      return;
    }

    final amount = double.parse(_amountController.text.trim());
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final repo = ref.read(budgetRepositoryProvider);

    if (widget.initialBudget == null) {
      final newBudget = Budget(
        id: 'budget-${const Uuid().v4()}',
        name: _nameController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        type: BudgetType.category,
        categoryId: _selectedCategoryId,
        amount: amount,
        period: _selectedPeriod,
        startDate: startOfMonth,
        endDate: endOfMonth,
        createdAt: now,
        updatedAt: now,
      );
      await repo.createBudget(newBudget);
    } else {
      final updatedBudget = widget.initialBudget!.copyWith(
        name: _nameController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        categoryId: _selectedCategoryId,
        amount: amount,
        period: _selectedPeriod,
        updatedAt: now,
      );
      await repo.updateBudget(updatedBudget);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
                      widget.initialBudget == null
                          ? 'Set Budget Cap'
                          : 'Edit Budget Cap',
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
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                      labelText: 'Budget Name *',
                      hintText: 'e.g. Groceries Cap'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 12),
                categoriesAsync.when(
                  data: (categories) {
                    if (_selectedCategoryId == null && categories.isNotEmpty) {
                      _selectedCategoryId = categories.first.id;
                    }
                    return DropdownButtonFormField<String>(
                      initialValue: _selectedCategoryId,
                      decoration:
                          const InputDecoration(labelText: 'Target Category *'),
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
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const SizedBox(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      labelText: 'Budget Limit Amount *', prefixText: '\$ '),
                  validator: (v) => v == null || double.tryParse(v) == null
                      ? 'Enter valid number'
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<BudgetPeriod>(
                  initialValue: _selectedPeriod,
                  decoration:
                      const InputDecoration(labelText: 'Reset Cycle Period'),
                  items: BudgetPeriod.values
                      .map((p) => DropdownMenuItem(
                            value: p,
                            child: Text(p.name.toUpperCase()),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedPeriod = val);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      hintText: 'Budget strategy notes'),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: Text(widget.initialBudget == null
                        ? 'Save Budget Cap'
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
