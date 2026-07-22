import 'package:flutter_test/flutter_test.dart';
import 'package:monetra/core/domain/entities/app_settings.dart';

void main() {
  group('Settings & Customization Engine Unit Tests', () {
    test('AppSettings copyWith cleanly updates theme and accent values', () {
      const settings = AppSettings();

      final updated = settings.copyWith(
        themeMode: AppThemeMode.oled,
        primaryAccentHex: '#10B981',
        isDeveloperMode: true,
      );

      expect(updated.themeMode, equals(AppThemeMode.oled));
      expect(updated.primaryAccentHex, equals('#10B981'));
      expect(updated.isDeveloperMode, isTrue);
    });

    test('AppSettings Equatable props comparison works as expected', () {
      const s1 = AppSettings(themeMode: AppThemeMode.dark, borderRadius: 16.0);
      const s2 = AppSettings(themeMode: AppThemeMode.dark, borderRadius: 16.0);

      expect(s1, equals(s2));
    });
  });
}
