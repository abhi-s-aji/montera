import 'package:equatable/equatable.dart';

enum AutoLockTimeout {
  immediate,
  oneMinute,
  fiveMinutes,
  fifteenMinutes,
  never
}

class SecurityConfig extends Equatable {
  final bool isAppLockEnabled;
  final String? pinHash;
  final int pinLength; // 4 or 6
  final bool isBiometricsEnabled;
  final AutoLockTimeout autoLockTimeout;
  final bool isPrivacyModeEnabled;
  final bool isDatabaseEncrypted;

  const SecurityConfig({
    this.isAppLockEnabled = false,
    this.pinHash,
    this.pinLength = 4,
    this.isBiometricsEnabled = false,
    this.autoLockTimeout = AutoLockTimeout.fiveMinutes,
    this.isPrivacyModeEnabled = false,
    this.isDatabaseEncrypted = true,
  });

  SecurityConfig copyWith({
    bool? isAppLockEnabled,
    String? pinHash,
    int? pinLength,
    bool? isBiometricsEnabled,
    AutoLockTimeout? autoLockTimeout,
    bool? isPrivacyModeEnabled,
    bool? isDatabaseEncrypted,
  }) {
    return SecurityConfig(
      isAppLockEnabled: isAppLockEnabled ?? this.isAppLockEnabled,
      pinHash: pinHash ?? this.pinHash,
      pinLength: pinLength ?? this.pinLength,
      isBiometricsEnabled: isBiometricsEnabled ?? this.isBiometricsEnabled,
      autoLockTimeout: autoLockTimeout ?? this.autoLockTimeout,
      isPrivacyModeEnabled: isPrivacyModeEnabled ?? this.isPrivacyModeEnabled,
      isDatabaseEncrypted: isDatabaseEncrypted ?? this.isDatabaseEncrypted,
    );
  }

  @override
  List<Object?> get props => [
        isAppLockEnabled,
        pinHash,
        pinLength,
        isBiometricsEnabled,
        autoLockTimeout,
        isPrivacyModeEnabled,
        isDatabaseEncrypted,
      ];
}

class SessionState extends Equatable {
  final bool isLocked;
  final DateTime lastActiveTimestamp;
  final int failedAttempts;

  const SessionState({
    this.isLocked = false,
    required this.lastActiveTimestamp,
    this.failedAttempts = 0,
  });

  SessionState copyWith({
    bool? isLocked,
    DateTime? lastActiveTimestamp,
    int? failedAttempts,
  }) {
    return SessionState(
      isLocked: isLocked ?? this.isLocked,
      lastActiveTimestamp: lastActiveTimestamp ?? this.lastActiveTimestamp,
      failedAttempts: failedAttempts ?? this.failedAttempts,
    );
  }

  @override
  List<Object?> get props => [isLocked, lastActiveTimestamp, failedAttempts];
}
