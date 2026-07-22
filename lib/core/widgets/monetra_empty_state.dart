import 'package:flutter/material.dart';
import 'package:monetra/core/theme/monetra_design_system.dart';

class MonetraEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  const MonetraEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textSecondary = theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey;

    Widget body = Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: MonetraDesignSystem.spaceXXL, vertical: 48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: MonetraDesignSystem.spaceXL),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: MonetraDesignSystem.spaceS),
            Text(
              description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textSecondary,
                height: 1.4,
              ),
            ),
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: MonetraDesignSystem.spaceXL),
              ElevatedButton(
                onPressed: onActionPressed,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );

    // Respect system reduced motion settings
    if (MediaQuery.of(context).accessibleNavigation) {
      return body;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1.0),
      duration: MonetraDesignSystem.durationNormal,
      curve: MonetraDesignSystem.curveDecelerate,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: AnimatedOpacity(
            opacity: scale == 0.95 ? 0.0 : 1.0,
            duration: MonetraDesignSystem.durationFast,
            child: child,
          ),
        );
      },
      child: body,
    );
  }
}
