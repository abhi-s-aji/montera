import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/app_settings.dart';
import 'repository_providers.dart';

final settingsSearchQueryProvider = StateProvider<String>((ref) => '');

class SettingsNotifier extends StateNotifier<AppSettings> {
  final Ref ref;

  SettingsNotifier(this.ref) : super(const AppSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final repo = ref.read(settingsRepositoryProvider);
    final settings = await repo.getSettings();
    state = settings;
  }

  Future<void> updateThemeMode(AppThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await ref.read(settingsRepositoryProvider).updateSettings(state);
  }

  Future<void> updatePrimaryAccent(String hex) async {
    state = state.copyWith(primaryAccentHex: hex);
    await ref.read(settingsRepositoryProvider).updateSettings(state);
  }

  Future<void> updateBaseCurrency(String currency) async {
    state = state.copyWith(baseCurrency: currency);
    await ref.read(settingsRepositoryProvider).updateSettings(state);
  }

  Future<void> updateFontFamily(String font) async {
    state = state.copyWith(fontFamily: font);
    await ref.read(settingsRepositoryProvider).updateSettings(state);
  }

  Future<void> updateBorderRadius(double radius) async {
    state = state.copyWith(borderRadius: radius);
    await ref.read(settingsRepositoryProvider).updateSettings(state);
  }

  Future<void> toggleDeveloperMode(bool enabled) async {
    state = state.copyWith(isDeveloperMode: enabled);
    await ref.read(settingsRepositoryProvider).updateSettings(state);
  }

  Future<void> toggleHighContrast(bool enabled) async {
    state = state.copyWith(isHighContrast: enabled);
    await ref.read(settingsRepositoryProvider).updateSettings(state);
  }

  Future<void> resetToDefaults() async {
    state = const AppSettings();
    await ref.read(settingsRepositoryProvider).updateSettings(state);
  }
}

final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(ref);
});
