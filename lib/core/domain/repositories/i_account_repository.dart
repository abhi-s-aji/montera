import '../entities/account.dart';

abstract class IAccountRepository {
  Stream<List<Account>> watchAllAccounts({bool includeArchived = false});
  Future<List<Account>> getAllAccounts({bool includeArchived = false});
  Future<Account?> getAccountById(String id);
  Future<void> createAccount(Account account);
  Future<void> updateAccount(Account account);
  Future<void> archiveAccount(String id, bool archiveStatus);
  Future<void> deleteAccount(String id);
  Future<Account> duplicateAccount(String id);
}
