import '../entities/app_settings.dart';

abstract class ISettingsRepository {
  Future<AppSettings> getSettings();
  Future<void> updateSettings(AppSettings settings);
}
