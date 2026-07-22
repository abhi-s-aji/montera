import 'package:flutter/material.dart';

import '../domain/entities/app_settings.dart';
import 'monetra_colors.dart';

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
      secondary: primaryAccent.withOpacity(0.8),
      onSecondary: Colors.white,
      surface: surface,
      onSurface: textPrimary,
      error: MonetraColors.expenseRed,
      onError: Colors.white,
    );

    final borderRadius = BorderRadius.circular(settings.borderRadius);

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      canvasColor: surface,
      cardColor: card,
      dividerColor: border,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: settings.fontFamily,
        ),
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
        hintStyle: TextStyle(color: textSecondary.withOpacity(0.7)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: border),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
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
    );
  }
}
