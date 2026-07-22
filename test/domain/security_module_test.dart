import 'package:flutter_test/flutter_test.dart';

import 'package:monetra/features/security/domain/entities/security_state.dart';
import 'package:monetra/features/security/services/security_services.dart';

void main() {
  group('Monetra Security & Privacy Engine Unit Tests', () {
    test('PinHasher hashes and verifies raw numeric PIN codes correctly', () {
      const rawPin = '1234';
      final hash = PinHasher.hashPin(rawPin);

      expect(hash, isNotEmpty);
      expect(PinHasher.verifyPin('1234', hash), isTrue);
      expect(PinHasher.verifyPin('9999', hash), isFalse);
    });

    test('PrivacyMasker masks amounts and text when Privacy Mode is enabled',
        () {
      const amount = 1450.50;
      const currency = 'USD';

      final unmasked = PrivacyMasker.maskAmount(amount, currency, false);
      expect(unmasked, equals('USD 1450.50'));

      final masked = PrivacyMasker.maskAmount(amount, currency, true);
      expect(masked, equals('••••••'));

      final maskedText = PrivacyMasker.maskText('Secret Note', true);
      expect(maskedText, equals('••••••••'));
    });

    test('AutoLockTimer calculates inactivity lock triggers correctly', () {
      final now = DateTime(2026, 7, 22, 12, 10);
      final active5MinAgo = DateTime(2026, 7, 22, 12, 5);

      final lock1Min = AutoLockTimer.shouldLock(
        lastActive: active5MinAgo,
        currentTime: now,
        timeout: AutoLockTimeout.oneMinute,
      );
      expect(lock1Min, isTrue);

      final lockNever = AutoLockTimer.shouldLock(
        lastActive: active5MinAgo,
        currentTime: now,
        timeout: AutoLockTimeout.never,
      );
      expect(lockNever, isFalse);
    });

    test('SecurityConfig copyWith cleanly updates security settings state', () {
      const config = SecurityConfig();
      final updated = config.copyWith(
        isAppLockEnabled: true,
        isPrivacyModeEnabled: true,
        pinLength: 6,
      );

      expect(updated.isAppLockEnabled, isTrue);
      expect(updated.isPrivacyModeEnabled, isTrue);
      expect(updated.pinLength, equals(6));
      expect(updated.autoLockTimeout, equals(AutoLockTimeout.fiveMinutes));
    });
  });
}
