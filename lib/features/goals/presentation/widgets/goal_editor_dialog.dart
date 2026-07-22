import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/domain/entities/goal.dart';
import '../../../../core/providers/account_providers.dart';
import '../../../../core/providers/repository_providers.dart';

class GoalEditorDialog extends ConsumerStatefulWidget {
  final Goal? initialGoal;

  const GoalEditorDialog({super.key, this.initialGoal});

  static Future<void> show(BuildContext context, {Goal? goal}) {
    return showDialog(
      context: context,
      builder: (ctx) => GoalEditorDialog(initialGoal: goal),
    );
  }

  @override
  ConsumerState<GoalEditorDialog> createState() => _GoalEditorDialogState();
}

class _GoalEditorDialogState extends ConsumerState<GoalEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _targetAmountController;
  late TextEditingController _currentAmountController;

  GoalType _selectedType = GoalType.savings;
  String? _selectedAccountId;
  DateTime _selectedTargetDate = DateTime.now().add(const Duration(days: 180));

  @override
  void initState() {
    super.initState();
    final g = widget.initialGoal;
    _titleController = TextEditingController(text: g?.title ?? '');
    _descController = TextEditingController(text: g?.description ?? '');
    _targetAmountController =
        TextEditingController(text: g != null ? g.targetAmount.toString() : '');
    _currentAmountController = TextEditingController(
        text: g != null ? g.currentAmount.toString() : '0.0');

    if (g != null) {
      _selectedType = g.type;
      _selectedAccountId = g.linkedAccountId;
      if (g.targetDate != null) _selectedTargetDate = g.targetDate!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final targetAmt = double.parse(_targetAmountController.text.trim());
    final currentAmt = double.parse(_currentAmountController.text.trim());
    final now = DateTime.now();
    final repo = ref.read(goalRepositoryProvider);

    if (widget.initialGoal == null) {
      final newGoal = Goal(
        id: 'goal-${const Uuid().v4()}',
        title: _titleController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        type: _selectedType,
        targetAmount: targetAmt,
        currentAmount: currentAmt,
        linkedAccountId: _selectedAccountId,
        targetDate: _selectedTargetDate,
        createdAt: now,
        updatedAt: now,
      );
      await repo.createGoal(newGoal);
    } else {
      final updatedGoal = widget.initialGoal!.copyWith(
        title: _titleController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        type: _selectedType,
        targetAmount: targetAmt,
        currentAmount: currentAmt,
        linkedAccountId: _selectedAccountId,
        targetDate: _selectedTargetDate,
        updatedAt: now,
      );
      await repo.updateGoal(updatedGoal);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsStreamProvider);

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
                      widget.initialGoal == null
                          ? 'Create Financial Goal'
                          : 'Edit Goal',
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
                  controller: _titleController,
                  decoration: const InputDecoration(
                      labelText: 'Goal Title *',
                      hintText: 'e.g. Emergency Fund'),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Title is required'
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<GoalType>(
                  initialValue: _selectedType,
                  decoration:
                      const InputDecoration(labelText: 'Goal Category Type'),
                  items: GoalType.values
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(t.name.toUpperCase()),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedType = val);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _targetAmountController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                            labelText: 'Target Amount *', prefixText: '\$ '),
                        validator: (v) =>
                            v == null || double.tryParse(v) == null
                                ? 'Enter valid number'
                                : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _currentAmountController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                            labelText: 'Current Saved', prefixText: '\$ '),
                        validator: (v) =>
                            v == null || double.tryParse(v) == null
                                ? 'Enter valid number'
                                : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                accountsAsync.when(
                  data: (accounts) {
                    return DropdownButtonFormField<String?>(
                      initialValue: _selectedAccountId,
                      decoration: const InputDecoration(
                          labelText: 'Linked Account (Optional)'),
                      items: [
                        const DropdownMenuItem<String?>(
                            value: null, child: Text('None')),
                        ...accounts.map((a) => DropdownMenuItem<String?>(
                              value: a.id,
                              child: Text(a.name),
                            )),
                      ],
                      onChanged: (val) =>
                          setState(() => _selectedAccountId = val),
                    );
                  },
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: Text(widget.initialGoal == null
                        ? 'Create Goal'
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
