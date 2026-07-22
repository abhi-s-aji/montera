import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/providers/settings_providers.dart';
import 'core/theme/monetra_colors.dart';
import 'core/theme/monetra_design_system.dart';
import 'core/theme/monetra_theme.dart';
import 'core/utils/app_router.dart';
import 'core/utils/monetra_logger.dart';
import 'features/search/presentation/widgets/command_palette_overlay.dart';

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
      themeAnimationDuration: MonetraDesignSystem.durationSlow,
      scrollBehavior: const MonetraScrollBehavior(),
    );
  }
}

class MonetraScrollBehavior extends MaterialScrollBehavior {
  const MonetraScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
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
    if (location.startsWith('/settings') ||
        location.startsWith('/backup') ||
        location.startsWith('/import') ||
        location.startsWith('/security') ||
        location.startsWith('/automation') ||
        location.startsWith('/performance') ||
        location.startsWith('/plugins')) {
      return 8;
    }
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

              Widget itemWidget = Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: InkWell(
                  onTap: () {
                    if (isDrawer) {
                      Navigator.of(context).pop();
                    }
                    _onItemTapped(index, context);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary.withValues(alpha: 0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        // Subtle active left indicator bar
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.easeOutCubic,
                          width: 3,
                          height: isSelected ? 16 : 0,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: isSelected ? 8 : 0,
                        ),
                        Icon(
                          item['icon'] as IconData,
                          size: 18,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.textTheme.bodyMedium?.color
                                  ?.withValues(alpha: 0.65),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.textTheme.bodyMedium?.color,
                            ),
                            child: Text(
                              item['label'] as String,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );

              if (index == 1) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 8, bottom: 6),
                      child: Text(
                        'MONEY',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.4),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    itemWidget,
                  ],
                );
              }

              if (index == 6) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 8, bottom: 6),
                      child: Text(
                        'INSIGHTS',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.4),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    itemWidget,
                  ],
                );
              }

              return itemWidget;
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

  void _openCommandPalette(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Command Palette',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) => const CommandPaletteOverlay(),
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = CurveTween(curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curve.animate(anim1),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.05),
              end: Offset.zero,
            ).animate(curve.animate(anim1)),
            child: child,
          ),
        );
      },
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
    ];

    Widget mainWidget;

    if (isMobile) {
      final String currentTitle;
      final String path = GoRouterState.of(context).uri.path;
      if (path.startsWith('/backup')) {
        currentTitle = 'Backup Studio';
      } else if (path.startsWith('/import')) {
        currentTitle = 'Import Studio';
      } else if (path.startsWith('/security')) {
        currentTitle = 'Security Studio';
      } else if (path.startsWith('/automation')) {
        currentTitle = 'Automation Studio';
      } else if (path.startsWith('/performance')) {
        currentTitle = 'Performance Studio';
      } else if (path.startsWith('/plugins')) {
        currentTitle = 'Plugin Studio';
      } else {
        currentTitle = selectedIndex >= 0 && selectedIndex < navItems.length
            ? navItems[selectedIndex]['label'] as String
            : 'Monetra';
      }

      mainWidget = Scaffold(
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
    } else {
      mainWidget = Scaffold(
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

    return CallbackShortcuts(
      bindings: {
        SingleActivator(LogicalKeyboardKey.keyK, control: !isMobile, meta: !isMobile): () {
          _openCommandPalette(context);
        },
      },
      child: Focus(
        autofocus: true,
        child: mainWidget,
      ),
    );
  }
}
