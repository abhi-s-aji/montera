import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/i_settings_repository.dart';

class SettingsRepositoryImpl implements ISettingsRepository {
  AppSettings _settings = const AppSettings();

  @override
  Future<AppSettings> getSettings() async {
    return _settings;
  }

  @override
  Future<void> updateSettings(AppSettings settings) async {
    _settings = settings;
  }
}
