import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/domain/entities/account.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/theme/monetra_colors.dart';

class AccountEditorDialog extends ConsumerStatefulWidget {
  final Account? initialAccount;

  const AccountEditorDialog({super.key, this.initialAccount});

  static Future<void> show(BuildContext context, {Account? account}) {
    return showDialog(
      context: context,
      builder: (ctx) => AccountEditorDialog(initialAccount: account),
    );
  }

  @override
  ConsumerState<AccountEditorDialog> createState() =>
      _AccountEditorDialogState();
}

class _AccountEditorDialogState extends ConsumerState<AccountEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _balanceController;
  late TextEditingController _institutionController;
  late TextEditingController _accountNumController;

  AccountType _selectedType = AccountType.checking;
  String _selectedCurrency = 'USD';
  String _selectedColorHex = '#6366F1';
  String _selectedIcon = 'account_balance';

  final List<String> _currencies = [
    'USD',
    'EUR',
    'GBP',
    'INR',
    'JPY',
    'CAD',
    'AUD'
  ];
  final List<String> _colors = [
    '#6366F1',
    '#10B981',
    '#EC4899',
    '#F59E0B',
    '#06B6D4',
    '#8B5CF6'
  ];

  @override
  void initState() {
    super.initState();
    final acc = widget.initialAccount;
    _nameController = TextEditingController(text: acc?.name ?? '');
    _descController = TextEditingController(text: acc?.description ?? '');
    _balanceController = TextEditingController(
        text: acc != null ? acc.openingBalance.toString() : '0.0');
    _institutionController =
        TextEditingController(text: acc?.institutionName ?? '');
    _accountNumController =
        TextEditingController(text: acc?.accountNumberMasked ?? '');

    if (acc != null) {
      _selectedType = acc.type;
      _selectedCurrency = acc.currency;
      _selectedColorHex = acc.colorHex;
      _selectedIcon = acc.icon;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _balanceController.dispose();
    _institutionController.dispose();
    _accountNumController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final openingBal = double.parse(_balanceController.text.trim());
    final now = DateTime.now();
    final repo = ref.read(accountRepositoryProvider);

    if (widget.initialAccount == null) {
      final newAcc = Account(
        id: 'acc-${const Uuid().v4()}',
        name: _nameController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        type: _selectedType,
        currency: _selectedCurrency,
        openingBalance: openingBal,
        balance: openingBal,
        icon: _selectedIcon,
        colorHex: _selectedColorHex,
        institutionName: _institutionController.text.trim().isEmpty
            ? null
            : _institutionController.text.trim(),
        accountNumberMasked: _accountNumController.text.trim().isEmpty
            ? null
            : _accountNumController.text.trim(),
        createdAt: now,
        updatedAt: now,
      );
      await repo.createAccount(newAcc);
    } else {
      final updatedAcc = widget.initialAccount!.copyWith(
        name: _nameController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        type: _selectedType,
        currency: _selectedCurrency,
        openingBalance: openingBal,
        balance: widget.initialAccount!.balance +
            (openingBal - widget.initialAccount!.openingBalance),
        icon: _selectedIcon,
        colorHex: _selectedColorHex,
        institutionName: _institutionController.text.trim().isEmpty
            ? null
            : _institutionController.text.trim(),
        accountNumberMasked: _accountNumController.text.trim().isEmpty
            ? null
            : _accountNumController.text.trim(),
        updatedAt: now,
      );
      await repo.updateAccount(updatedAcc);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
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
                      widget.initialAccount == null
                          ? 'Create Financial Account'
                          : 'Edit Account',
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
                      labelText: 'Account Name *',
                      hintText: 'e.g. Primary Checking'),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Account name is required'
                      : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<AccountType>(
                        initialValue: _selectedType,
                        decoration:
                            const InputDecoration(labelText: 'Account Type'),
                        items: AccountType.values
                            .map((t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(t.name.toUpperCase()),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedType = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedCurrency,
                        decoration:
                            const InputDecoration(labelText: 'Currency'),
                        items: _currencies
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null)
                            setState(() => _selectedCurrency = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _balanceController,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true, signed: true),
                  decoration: const InputDecoration(
                      labelText: 'Opening Balance', hintText: '0.00'),
                  validator: (v) => v == null || double.tryParse(v) == null
                      ? 'Enter valid number'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _institutionController,
                  decoration: const InputDecoration(
                      labelText: 'Institution Name (Optional)',
                      hintText: 'e.g. Chase Bank'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _accountNumController,
                  decoration: const InputDecoration(
                      labelText: 'Account Number Masked (Optional)',
                      hintText: '•••• 4821'),
                ),
                const SizedBox(height: 16),
                Text('Color Palette',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyMedium?.color)),
                const SizedBox(height: 8),
                Row(
                  children: _colors.map((hex) {
                    final color = MonetraColors.hexToColor(hex);
                    final isSelected = _selectedColorHex == hex;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColorHex = hex),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: Text(widget.initialAccount == null
                        ? 'Create Account'
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
