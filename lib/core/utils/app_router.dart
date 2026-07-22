import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/accounts/presentation/pages/accounts_page.dart';
import '../../features/analytics/presentation/pages/analytics_page.dart';
import '../../features/budgets/presentation/pages/budgets_page.dart';
import '../../features/categories/presentation/pages/categories_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/goals/presentation/pages/goals_page.dart';
import '../../features/automation/presentation/pages/recurring_page.dart';
import '../../features/backup/presentation/pages/backup_page.dart';
import '../../features/import/presentation/pages/import_page.dart';
import '../../features/performance/presentation/pages/performance_page.dart';
import '../../features/plugins/presentation/pages/plugin_manager_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/security/presentation/pages/security_settings_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/transactions/presentation/pages/transactions_page.dart';
import '../../main.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/dashboard',
    routes: [
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) {
          return MonetraWorkspaceShell(child: child);
        },
        routes: [
          _buildFadeRoute('/dashboard', 'dashboard', const DashboardPage()),
          _buildFadeRoute('/transactions', 'transactions', const TransactionsPage()),
          _buildFadeRoute('/accounts', 'accounts', const AccountsPage()),
          _buildFadeRoute('/budgets', 'budgets', const BudgetsPage()),
          _buildFadeRoute('/categories', 'categories', const CategoriesPage()),
          _buildFadeRoute('/goals', 'goals', const GoalsPage()),
          _buildFadeRoute('/analytics', 'analytics', const AnalyticsPage()),
          _buildFadeRoute('/reports', 'reports', const ReportsPage()),
          _buildFadeRoute('/settings', 'settings', const SettingsPage()),
          _buildFadeRoute('/backup', 'backup', const BackupPage()),
          _buildFadeRoute('/import', 'import', const ImportPage()),
          _buildFadeRoute('/security', 'security', const SecuritySettingsPage()),
          _buildFadeRoute('/automation', 'automation', const RecurringPage()),
          _buildFadeRoute('/search', 'search', const SearchPage()),
          _buildFadeRoute('/performance', 'performance', const PerformancePage()),
          _buildFadeRoute('/plugins', 'plugins', const PluginManagerPage()),
        ],
      ),
    ],
  );

  static GoRoute _buildFadeRoute(String path, String name, Widget child) {
    return GoRoute(
      path: path,
      name: name,
      pageBuilder: (context, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        child: child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }
}
