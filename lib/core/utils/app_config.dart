enum AppEnvironment { development, staging, production }

class AppConfig {
  final String appName;
  final String version;
  final AppEnvironment environment;
  final bool enableDebugLogs;
  final bool enableExperimentalPlugins;

  const AppConfig({
    required this.appName,
    required this.version,
    required this.environment,
    this.enableDebugLogs = true,
    this.enableExperimentalPlugins = false,
  });

  static const AppConfig dev = AppConfig(
    appName: 'Monetra (Dev)',
    version: '1.0.0-dev',
    environment: AppEnvironment.development,
    enableDebugLogs: true,
    enableExperimentalPlugins: true,
  );

  static const AppConfig prod = AppConfig(
    appName: 'Monetra',
    version: '1.0.0',
    environment: AppEnvironment.production,
    enableDebugLogs: false,
    enableExperimentalPlugins: false,
  );
}
