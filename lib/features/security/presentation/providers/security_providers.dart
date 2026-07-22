import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monetra/features/security/domain/entities/security_state.dart';

final securityConfigProvider =
    StateProvider<SecurityConfig>((ref) => const SecurityConfig());

final sessionStateProvider = StateProvider<SessionState>(
  (ref) => SessionState(lastActiveTimestamp: DateTime.now()),
);

final privacyModeProvider = Provider<bool>((ref) {
  final config = ref.watch(securityConfigProvider);
  return config.isPrivacyModeEnabled;
});
