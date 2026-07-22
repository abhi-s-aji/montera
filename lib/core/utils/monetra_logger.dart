import 'package:flutter/foundation.dart';

/// Structured privacy-aware logging framework for Monetra.
class MonetraLogger {
  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint('[DEBUG] [$timestamp] $message');
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint('[INFO] [$timestamp] $message');
    }
  }

  static void warning(String message, [Object? error, StackTrace? stackTrace]) {
    final timestamp = DateTime.now().toIso8601String();
    debugPrint('[WARNING] [$timestamp] $message');
    if (error != null) debugPrint('Error: $error');
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    final timestamp = DateTime.now().toIso8601String();
    debugPrint('[ERROR] [$timestamp] $message');
    if (error != null) debugPrint('Error: $error');
    if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
  }

  /// Sanitizes sensitive user inputs to ensure zero financial data leakage in logs.
  static String maskSensitive(String input) {
    if (input.length <= 4) return '***';
    return '${input.substring(0, 2)}***${input.substring(input.length - 2)}';
  }
}
