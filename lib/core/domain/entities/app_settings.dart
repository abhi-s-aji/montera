import 'package:equatable/equatable.dart';

enum AppThemeMode { system, dark, light, oled }

class AppSettings extends Equatable {
  final AppThemeMode themeMode;
  final String primaryAccentHex;
  final String baseCurrency;
  final String fontFamily;
  final double borderRadius;
  final bool enableAnimations;
  final bool enableSecurityLock;
  final bool isDeveloperMode;
  final bool isHighContrast;
  final String dateFormat;
  final int weekStartDay; // 1 = Monday, 7 = Sunday

  const AppSettings({
    this.themeMode = AppThemeMode.dark,
    this.primaryAccentHex = '#6366F1', // Indigo accent
    this.baseCurrency = 'USD',
    this.fontFamily = 'Inter',
    this.borderRadius = 12.0,
    this.enableAnimations = true,
    this.enableSecurityLock = false,
    this.isDeveloperMode = false,
    this.isHighContrast = false,
    this.dateFormat = 'YYYY-MM-DD',
    this.weekStartDay = 1,
  });

  AppSettings copyWith({
    AppThemeMode? themeMode,
    String? primaryAccentHex,
    String? baseCurrency,
    String? fontFamily,
    double? borderRadius,
    bool? enableAnimations,
    bool? enableSecurityLock,
    bool? isDeveloperMode,
    bool? isHighContrast,
    String? dateFormat,
    int? weekStartDay,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      primaryAccentHex: primaryAccentHex ?? this.primaryAccentHex,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      fontFamily: fontFamily ?? this.fontFamily,
      borderRadius: borderRadius ?? this.borderRadius,
      enableAnimations: enableAnimations ?? this.enableAnimations,
      enableSecurityLock: enableSecurityLock ?? this.enableSecurityLock,
      isDeveloperMode: isDeveloperMode ?? this.isDeveloperMode,
      isHighContrast: isHighContrast ?? this.isHighContrast,
      dateFormat: dateFormat ?? this.dateFormat,
      weekStartDay: weekStartDay ?? this.weekStartDay,
    );
  }

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.name,
        'primaryAccentHex': primaryAccentHex,
        'baseCurrency': baseCurrency,
        'fontFamily': fontFamily,
        'borderRadius': borderRadius,
        'enableAnimations': enableAnimations,
        'enableSecurityLock': enableSecurityLock,
        'isDeveloperMode': isDeveloperMode,
        'isHighContrast': isHighContrast,
        'dateFormat': dateFormat,
        'weekStartDay': weekStartDay,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: AppThemeMode.values.firstWhere(
          (e) => e.name == json['themeMode'],
          orElse: () => AppThemeMode.dark),
      primaryAccentHex: json['primaryAccentHex'] as String? ?? '#6366F1',
      baseCurrency: json['baseCurrency'] as String? ?? 'USD',
      fontFamily: json['fontFamily'] as String? ?? 'Inter',
      borderRadius: (json['borderRadius'] as num? ?? 12.0).toDouble(),
      enableAnimations: json['enableAnimations'] as bool? ?? true,
      enableSecurityLock: json['enableSecurityLock'] as bool? ?? false,
      isDeveloperMode: json['isDeveloperMode'] as bool? ?? false,
      isHighContrast: json['isHighContrast'] as bool? ?? false,
      dateFormat: json['dateFormat'] as String? ?? 'YYYY-MM-DD',
      weekStartDay: json['weekStartDay'] as int? ?? 1,
    );
  }

  @override
  List<Object?> get props => [
        themeMode,
        primaryAccentHex,
        baseCurrency,
        fontFamily,
        borderRadius,
        enableAnimations,
        enableSecurityLock,
        isDeveloperMode,
        isHighContrast,
        dateFormat,
        weekStartDay,
      ];
}
