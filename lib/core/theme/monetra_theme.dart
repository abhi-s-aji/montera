import 'dart:ui';
import 'package:flutter/material.dart';

import '../domain/entities/app_settings.dart';
import 'monetra_colors.dart';
import 'monetra_design_system.dart';

class MonetraTheme {
  static ThemeData buildTheme(AppSettings settings) {
    final isDark = settings.themeMode == AppThemeMode.dark ||
        settings.themeMode == AppThemeMode.oled;
    final isOled = settings.themeMode == AppThemeMode.oled;

    final primaryAccent = MonetraColors.hexToColor(settings.primaryAccentHex);

    final bg = isOled
        ? MonetraColors.oledBackground
        : (isDark
            ? MonetraColors.darkBackground
            : MonetraColors.lightBackground);

    final surface = isOled
        ? MonetraColors.oledSurface
        : (isDark ? MonetraColors.darkSurface : MonetraColors.lightSurface);

    final card = isOled
        ? MonetraColors.oledCard
        : (isDark ? MonetraColors.darkCard : MonetraColors.lightCard);

    final border = isOled
        ? MonetraColors.oledBorder
        : (isDark ? MonetraColors.darkBorder : MonetraColors.lightBorder);

    final textPrimary =
        isDark ? MonetraColors.darkTextPrimary : MonetraColors.lightTextPrimary;
    final textSecondary = isDark
        ? MonetraColors.darkTextSecondary
        : MonetraColors.lightTextSecondary;

    final colorScheme = ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: primaryAccent,
      onPrimary: Colors.white,
      secondary: primaryAccent.withValues(alpha: 0.8),
      onSecondary: Colors.white,
      surface: surface,
      onSurface: textPrimary,
      error: MonetraColors.expenseRed,
      onError: Colors.white,
    );

    // Using Design System Tokens
    final borderRadius = BorderRadius.circular(MonetraDesignSystem.radiusL);

    final textTheme = const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5, fontFeatures: [FontFeature.tabularFigures()]),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5, fontFeatures: [FontFeature.tabularFigures()]),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.5, fontFeatures: [FontFeature.tabularFigures()]),
      headlineLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFeatures: [FontFeature.tabularFigures()]),
      headlineMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, fontFeatures: [FontFeature.tabularFigures()]),
      headlineSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFeatures: [FontFeature.tabularFigures()]),
      titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFeatures: [FontFeature.tabularFigures()]),
      titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFeatures: [FontFeature.tabularFigures()]),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFeatures: [FontFeature.tabularFigures()]),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, fontFeatures: [FontFeature.tabularFigures()]),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, fontFeatures: [FontFeature.tabularFigures()]),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, fontFeatures: [FontFeature.tabularFigures()]),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFeatures: [FontFeature.tabularFigures()]),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, fontFeatures: [FontFeature.tabularFigures()]),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, fontFeatures: [FontFeature.tabularFigures()]),
    ).apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
      fontFamily: settings.fontFamily,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      canvasColor: surface,
      cardColor: card,
      dividerColor: border,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineLarge?.copyWith(color: textPrimary),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(color: border, width: 1.0),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: MonetraDesignSystem.spaceL, vertical: MonetraDesignSystem.spaceM),
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: primaryAccent, width: 1.5),
        ),
        labelStyle: TextStyle(color: textSecondary),
        hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.7)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: MonetraDesignSystem.spaceXL, vertical: MonetraDesignSystem.spaceL),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MonetraDesignSystem.radiusM)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          animationDuration: MonetraDesignSystem.durationFast,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: border),
          padding: const EdgeInsets.symmetric(horizontal: MonetraDesignSystem.spaceXL, vertical: MonetraDesignSystem.spaceL),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MonetraDesignSystem.radiusM)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          animationDuration: MonetraDesignSystem.durationFast,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(color: border),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: card,
        contentTextStyle: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
        elevation: 6,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(color: border, width: 1.0),
        ),
      ),
    );
  }
}
