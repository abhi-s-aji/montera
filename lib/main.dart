import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/providers/settings_providers.dart';
import 'core/theme/monetra_colors.dart';
import 'core/theme/monetra_theme.dart';
import 'core/utils/app_router.dart';
import 'core/utils/monetra_logger.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Centralized Flutter Error Catching
  FlutterError.onError = (FlutterErrorDetails details) {
    MonetraLogger.error(
        'Unhandled Flutter Error', details.exception, details.stack);
  };

  runApp(
    const ProviderScope(
      child: MonetraApp(),
    ),
  );
}

class MonetraApp extends ConsumerWidget {
  const MonetraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final theme = MonetraTheme.buildTheme(settings);

    return MaterialApp.router(
      title: 'Monetra',
      debugShowCheckedModeBanner: false,
      theme: theme,
      routerConfig: AppRouter.router,
    );
  }
}

class MonetraWorkspaceShell extends StatelessWidget {
  final Widget child;

  const MonetraWorkspaceShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/transactions')) return 1;
    if (location.startsWith('/accounts')) return 2;
    if (location.startsWith('/budgets')) return 3;
    if (location.startsWith('/categories')) return 4;
    if (location.startsWith('/goals')) return 5;
    if (location.startsWith('/analytics')) return 6;
    if (location.startsWith('/reports')) return 7;
    if (location.startsWith('/settings')) return 8;
    if (location.startsWith('/backup')) return 9;
    if (location.startsWith('/import')) return 10;
    if (location.startsWith('/security')) return 11;
    if (location.startsWith('/automation')) return 12;
    if (location.startsWith('/search')) return 13;
    if (location.startsWith('/performance')) return 14;
    if (location.startsWith('/plugins')) return 15;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/transactions');
        break;
      case 2:
        context.go('/accounts');
        break;
      case 3:
        context.go('/budgets');
        break;
      case 4:
        context.go('/categories');
        break;
      case 5:
        context.go('/goals');
        break;
      case 6:
        context.go('/analytics');
        break;
      case 7:
        context.go('/reports');
        break;
      case 8:
        context.go('/settings');
        break;
      case 9:
        context.go('/backup');
        break;
      case 10:
        context.go('/import');
        break;
      case 11:
        context.go('/security');
        break;
      case 12:
        context.go('/automation');
        break;
      case 13:
        context.go('/search');
        break;
      case 14:
        context.go('/performance');
        break;
      case 15:
        context.go('/plugins');
        break;
    }
  }

  Widget _buildNavColumn(
    BuildContext context,
    ThemeData theme,
    int selectedIndex,
    List<Map<String, dynamic>> navItems, {
    bool isDrawer = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header & Logo
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monetra',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Personal Finance',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.textTheme.bodyMedium?.color
                          ?.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        const SizedBox(height: 12),
        // Navigation Links
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: navItems.length,
            itemBuilder: (context, index) {
              final item = navItems[index];
              final isSelected = selectedIndex == index;

              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: InkWell(
                  onTap: () {
                    if (isDrawer) {
                      Navigator.of(context).pop();
                    }
                    _onItemTapped(index, context);
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          size: 18,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.textTheme.bodyMedium?.color
                                  ?.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          item['label'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Offline Privacy Badge Footer
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: MonetraColors.incomeGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: MonetraColors.incomeGreen.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.circle,
                    color: MonetraColors.incomeGreen, size: 8),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Offline Vault Active',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedIndex = _calculateSelectedIndex(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    final navItems = [
      {'icon': Icons.dashboard_rounded, 'label': 'Dashboard'},
      {'icon': Icons.receipt_long_rounded, 'label': 'Transactions'},
      {'icon': Icons.account_balance_wallet_rounded, 'label': 'Accounts'},
      {'icon': Icons.pie_chart_rounded, 'label': 'Budgets'},
      {'icon': Icons.category_rounded, 'label': 'Categories'},
      {'icon': Icons.flag_rounded, 'label': 'Goals'},
      {'icon': Icons.analytics_rounded, 'label': 'Analytics'},
      {'icon': Icons.description_rounded, 'label': 'Reports'},
      {'icon': Icons.settings_rounded, 'label': 'Settings'},
      {'icon': Icons.backup_rounded, 'label': 'Backup Studio'},
      {'icon': Icons.upload_file_rounded, 'label': 'Import Studio'},
      {'icon': Icons.security_rounded, 'label': 'Security Studio'},
      {'icon': Icons.autorenew_rounded, 'label': 'Automation Studio'},
      {'icon': Icons.search_rounded, 'label': 'Global Search'},
      {'icon': Icons.speed_rounded, 'label': 'Performance Studio'},
      {'icon': Icons.extension_rounded, 'label': 'Plugin Studio'},
    ];

    if (isMobile) {
      final currentTitle = navItems[selectedIndex]['label'] as String;

      return Scaffold(
        appBar: AppBar(
          title: Text(
            currentTitle,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          elevation: 0,
        ),
        drawer: Drawer(
          child: SafeArea(
            child: _buildNavColumn(
              context,
              theme,
              selectedIndex,
              navItems,
              isDrawer: true,
            ),
          ),
        ),
        body: Container(
          color: theme.scaffoldBackgroundColor,
          child: child,
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navigation Rail (Desktop / Widescreen)
          Container(
            width: 220,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                right: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.4),
                  width: 1.0,
                ),
              ),
            ),
            child: _buildNavColumn(
              context,
              theme,
              selectedIndex,
              navItems,
              isDrawer: false,
            ),
          ),
          // Main Workspace Page Area
          Expanded(
            child: Container(
              color: theme.scaffoldBackgroundColor,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
