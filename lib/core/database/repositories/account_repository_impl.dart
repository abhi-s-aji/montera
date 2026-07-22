import 'dart:async';

import '../../domain/entities/account.dart';
import '../../domain/repositories/i_account_repository.dart';

class AccountRepositoryImpl implements IAccountRepository {
  final List<Account> _accounts = [];
  final StreamController<List<Account>> _streamController =
      StreamController<List<Account>>.broadcast();

  AccountRepositoryImpl([List<Account>? initialAccounts]) {
    if (initialAccounts != null) {
      _accounts.addAll(initialAccounts);
    } else {
      _seedDefaultAccounts();
    }
    _emit();
  }

  void _seedDefaultAccounts() {
    final now = DateTime.now();
    _accounts.addAll([
      Account(
        id: 'acc-checking-1',
        name: 'Primary Checking',
        description: 'Main salary and billing account',
        type: AccountType.checking,
        currency: 'USD',
        openingBalance: 12000.00,
        balance: 14250.50,
        icon: 'account_balance',
        colorHex: '#6366F1',
        institutionName: 'Chase Bank',
        accountNumberMasked: '•••• 4821',
        createdAt: now,
        updatedAt: now,
      ),
      Account(
        id: 'acc-savings-1',
        name: 'High-Yield Savings',
        description: 'Emergency fund & liquid savings',
        type: AccountType.savings,
        currency: 'USD',
        openingBalance: 5000.00,
        balance: 5559.25,
        icon: 'savings',
        colorHex: '#10B981',
        institutionName: 'Ally Bank',
        accountNumberMasked: '•••• 9102',
        createdAt: now,
        updatedAt: now,
      ),
      Account(
        id: 'acc-credit-1',
        name: 'Sapphire Credit Card',
        description: 'Daily travel & points card',
        type: AccountType.creditCard,
        currency: 'USD',
        openingBalance: 0.0,
        balance: -196.29,
        icon: 'credit_card',
        colorHex: '#EC4899',
        institutionName: 'Chase',
        accountNumberMasked: '•••• 1104',
        createdAt: now,
        updatedAt: now,
      ),
    ]);
  }

  void _emit() {
    final active = _accounts.where((a) => !a.isDeleted).toList();
    _streamController.add(active);
  }

  @override
  Stream<List<Account>> watchAllAccounts({bool includeArchived = false}) {
    return _streamController.stream.map(
      (list) => list.where((a) => includeArchived || !a.isArchived).toList(),
    );
  }

  @override
  Future<List<Account>> getAllAccounts({bool includeArchived = false}) async {
    return _accounts
        .where((a) => !a.isDeleted && (includeArchived || !a.isArchived))
        .toList();
  }

  @override
  Future<Account?> getAccountById(String id) async {
    try {
      return _accounts.firstWhere((a) => a.id == id && !a.isDeleted);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> createAccount(Account account) async {
    _accounts.add(account);
    _emit();
  }

  @override
  Future<void> updateAccount(Account account) async {
    final index = _accounts.indexWhere((a) => a.id == account.id);
    if (index != -1) {
      _accounts[index] = account.copyWith(
        updatedAt: DateTime.now(),
        version: account.version + 1,
      );
      _emit();
    }
  }

  @override
  Future<void> archiveAccount(String id, bool archiveStatus) async {
    final index = _accounts.indexWhere((a) => a.id == id);
    if (index != -1) {
      _accounts[index] = _accounts[index].copyWith(
        isArchived: archiveStatus,
        updatedAt: DateTime.now(),
      );
      _emit();
    }
  }

  @override
  Future<void> deleteAccount(String id) async {
    final index = _accounts.indexWhere((a) => a.id == id);
    if (index != -1) {
      _accounts[index] = _accounts[index].copyWith(
        isDeleted: true,
        updatedAt: DateTime.now(),
      );
      _emit();
    }
  }

  @override
  Future<Account> duplicateAccount(String id) async {
    final original = await getAccountById(id);
    if (original == null) throw Exception('Account not found');

    final now = DateTime.now();
    final duplicate = original.copyWith(
      id: 'acc-${now.millisecondsSinceEpoch}',
      name: '${original.name} (Copy)',
      createdAt: now,
      updatedAt: now,
      version: 1,
    );
    await createAccount(duplicate);
    return duplicate;
  }
}
