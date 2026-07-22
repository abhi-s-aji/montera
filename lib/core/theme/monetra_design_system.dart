import 'package:flutter/material.dart';

class MonetraDesignSystem {
  // Spacing Tokens
  static const double spaceXS = 4.0;
  static const double spaceS = 8.0;
  static const double spaceM = 12.0;
  static const double spaceL = 16.0;
  static const double spaceXL = 24.0;
  static const double spaceXXL = 32.0;
  static const double space3XL = 48.0;

  // Corner Radius Tokens
  static const double radiusS = 6.0;
  static const double radiusM = 10.0;
  static const double radiusL = 14.0;
  static const double radiusXL = 18.0;
  static const double radiusXXL = 24.0;
  static const double radiusRound = 999.0;

  // Motion Duration Tokens
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 200);
  static const Duration durationSlow = Duration(milliseconds: 300);

  // Animation Curves
  static const Curve curveDefault = Curves.easeInOut;
  static const Curve curveDecelerate = Curves.easeOutCubic;
  static const Curve curveElastic = Curves.easeOutBack;

  // Elevation (using modern subtle shadows instead of heavy elevations)
  static List<BoxShadow> getShadowSubtle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.03),
        blurRadius: 4,
        offset: const Offset(0, 2),
      )
    ];
  }

  static List<BoxShadow> getShadowMedium(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: isDark ? Colors.black.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.01),
        blurRadius: 2,
        offset: const Offset(0, 1),
      )
    ];
  }

  static List<BoxShadow> getShadowHigh(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.08),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: isDark ? Colors.black.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.02),
        blurRadius: 4,
        offset: const Offset(0, 2),
      )
    ];
  }
}
