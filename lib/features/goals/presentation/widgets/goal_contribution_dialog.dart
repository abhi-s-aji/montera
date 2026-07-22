import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/entities/goal.dart';
import '../../../../core/providers/repository_providers.dart';

class GoalContributionDialog extends ConsumerStatefulWidget {
  final Goal goal;
  final bool isWithdrawal;

  const GoalContributionDialog(
      {super.key, required this.goal, this.isWithdrawal = false});

  static Future<void> show(BuildContext context,
      {required Goal goal, bool isWithdrawal = false}) {
    return showDialog(
      context: context,
      builder: (ctx) =>
          GoalContributionDialog(goal: goal, isWithdrawal: isWithdrawal),
    );
  }

  @override
  ConsumerState<GoalContributionDialog> createState() =>
      _GoalContributionDialogState();
}

class _GoalContributionDialogState
    extends ConsumerState<GoalContributionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(_amountController.text.trim());
    final repo = ref.read(goalRepositoryProvider);

    if (widget.isWithdrawal) {
      await repo.withdrawFromGoal(goalId: widget.goal.id, amount: amount);
    } else {
      await repo.contributeToGoal(goalId: widget.goal.id, amount: amount);
    }

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(widget.isWithdrawal
                ? 'Withdrew \$${amount.toStringAsFixed(2)} from goal'
                : 'Contributed \$${amount.toStringAsFixed(2)} to goal!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24.0),
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
                    widget.isWithdrawal
                        ? 'Withdraw from ${widget.goal.title}'
                        : 'Contribute to ${widget.goal.title}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: widget.isWithdrawal
                      ? 'Withdrawal Amount'
                      : 'Contribution Amount',
                  prefixText: '\$ ',
                ),
                validator: (v) => v == null ||
                        double.tryParse(v) == null ||
                        double.parse(v) <= 0
                    ? 'Enter valid positive amount'
                    : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(widget.isWithdrawal
                      ? 'Withdraw Savings'
                      : 'Add Savings Contribution'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
