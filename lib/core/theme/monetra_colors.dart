import 'package:flutter/material.dart';

class MonetraColors {
  // Base Dark Theme Colors (Calm Slate/Charcoal)
  static const Color darkBackground = Color(0xFF0F111A);
  static const Color darkSurface = Color(0xFF161925);
  static const Color darkCard = Color(0xFF1E2235);
  static const Color darkBorder = Color(0xFF2D324F);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // OLED Theme Colors
  static const Color oledBackground = Color(0xFF000000);
  static const Color oledSurface = Color(0xFF090A0F);
  static const Color oledCard = Color(0xFF12141F);
  static const Color oledBorder = Color(0xFF202336);

  // Light Theme Colors (Soft Slate/Cool Gray)
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // Financial Status Colors (Calm and Trustworthy Semantics)
  static const Color incomeGreen = Color(0xFF10B981); // Emerald
  static const Color expenseRed = Color(0xFFEF4444);  // Softer Rose Red
  static const Color transferBlue = Color(0xFF3B82F6); // Calm Indigo/Blue
  static const Color warningAmber = Color(0xFFF59E0B); // Amber Warning

  static Color hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static String colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }
}
