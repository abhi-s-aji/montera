import 'package:monetra/features/security/domain/entities/security_state.dart';

class PinHasher {
  static String hashPin(String rawPin) {
    int hash = 0;
    for (int i = 0; i < rawPin.length; i++) {
      hash = (hash * 31 + rawPin.codeUnitAt(i)) & 0xFFFFFFFF;
    }
    return 'pin_hash_${hash.toRadixString(16)}';
  }

  static bool verifyPin(String rawPin, String expectedHash) {
    return hashPin(rawPin) == expectedHash;
  }
}

class PrivacyMasker {
  static String maskAmount(double amount, String currency, bool isPrivacyMode) {
    if (isPrivacyMode) {
      return '••••••';
    }
    return '$currency ${amount.toStringAsFixed(2)}';
  }

  static String maskText(String text, bool isPrivacyMode) {
    if (isPrivacyMode) {
      return '••••••••';
    }
    return text;
  }
}

class AutoLockTimer {
  static bool shouldLock({
    required DateTime lastActive,
    required DateTime currentTime,
    required AutoLockTimeout timeout,
  }) {
    if (timeout == AutoLockTimeout.never) return false;
    if (timeout == AutoLockTimeout.immediate) return true;

    final differenceMinutes = currentTime.difference(lastActive).inMinutes;

    switch (timeout) {
      case AutoLockTimeout.oneMinute:
        return differenceMinutes >= 1;
      case AutoLockTimeout.fiveMinutes:
        return differenceMinutes >= 5;
      case AutoLockTimeout.fifteenMinutes:
        return differenceMinutes >= 15;
      default:
        return false;
    }
  }
}
