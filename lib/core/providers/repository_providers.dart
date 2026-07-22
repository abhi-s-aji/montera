import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/repositories/account_repository_impl.dart';
import '../database/repositories/budget_repository_impl.dart';
import '../database/repositories/category_repository_impl.dart';
import '../database/repositories/goal_repository_impl.dart';
import '../database/repositories/settings_repository_impl.dart';
import '../database/repositories/transaction_repository_impl.dart';
import '../domain/repositories/i_account_repository.dart';
import '../domain/repositories/i_budget_repository.dart';
import '../domain/repositories/i_category_repository.dart';
import '../domain/repositories/i_goal_repository.dart';
import '../domain/repositories/i_settings_repository.dart';
import '../domain/repositories/i_transaction_repository.dart';

final accountRepositoryProvider = Provider<IAccountRepository>((ref) {
  return AccountRepositoryImpl();
});

final categoryRepositoryProvider = Provider<ICategoryRepository>((ref) {
  return CategoryRepositoryImpl();
});

final transactionRepositoryProvider = Provider<ITransactionRepository>((ref) {
  return TransactionRepositoryImpl();
});

final budgetRepositoryProvider = Provider<IBudgetRepository>((ref) {
  return BudgetRepositoryImpl();
});

final settingsRepositoryProvider = Provider<ISettingsRepository>((ref) {
  return SettingsRepositoryImpl();
});

final goalRepositoryProvider = Provider<IGoalRepository>((ref) {
  return GoalRepositoryImpl();
});
