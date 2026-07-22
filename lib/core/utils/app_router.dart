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
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/transactions',
            name: 'transactions',
            builder: (context, state) => const TransactionsPage(),
          ),
          GoRoute(
            path: '/accounts',
            name: 'accounts',
            builder: (context, state) => const AccountsPage(),
          ),
          GoRoute(
            path: '/budgets',
            name: 'budgets',
            builder: (context, state) => const BudgetsPage(),
          ),
          GoRoute(
            path: '/categories',
            name: 'categories',
            builder: (context, state) => const CategoriesPage(),
          ),
          GoRoute(
            path: '/goals',
            name: 'goals',
            builder: (context, state) => const GoalsPage(),
          ),
          GoRoute(
            path: '/analytics',
            name: 'analytics',
            builder: (context, state) => const AnalyticsPage(),
          ),
          GoRoute(
            path: '/reports',
            name: 'reports',
            builder: (context, state) => const ReportsPage(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: '/backup',
            name: 'backup',
            builder: (context, state) => const BackupPage(),
          ),
          GoRoute(
            path: '/import',
            name: 'import',
            builder: (context, state) => const ImportPage(),
          ),
          GoRoute(
            path: '/security',
            name: 'security',
            builder: (context, state) => const SecuritySettingsPage(),
          ),
          GoRoute(
            path: '/automation',
            name: 'automation',
            builder: (context, state) => const RecurringPage(),
          ),
          GoRoute(
            path: '/search',
            name: 'search',
            builder: (context, state) => const SearchPage(),
          ),
          GoRoute(
            path: '/performance',
            name: 'performance',
            builder: (context, state) => const PerformancePage(),
          ),
          GoRoute(
            path: '/plugins',
            name: 'plugins',
            builder: (context, state) => const PluginManagerPage(),
          ),
        ],
      ),
    ],
  );
}
