import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monetra/core/widgets/monetra_card.dart';
import 'package:monetra/features/security/domain/entities/security_state.dart';
import 'package:monetra/features/security/presentation/providers/security_providers.dart';
import 'package:monetra/features/security/services/security_services.dart';

class SecuritySettingsPage extends ConsumerStatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  ConsumerState<SecuritySettingsPage> createState() =>
      _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends ConsumerState<SecuritySettingsPage> {
  final TextEditingController _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _showSetPinDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Setup Access PIN'),
        content: TextField(
          controller: _pinController,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 4,
          decoration: const InputDecoration(
            hintText: 'Enter 4-digit numeric PIN',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (_pinController.text.length == 4) {
                final hash = PinHasher.hashPin(_pinController.text);
                ref.read(securityConfigProvider.notifier).state =
                    ref.read(securityConfigProvider).copyWith(
                          isAppLockEnabled: true,
                          pinHash: hash,
                        );
                _pinController.clear();
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Access PIN updated successfully!')),
                );
              }
            },
            child: const Text('Save PIN'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = ref.watch(securityConfigProvider);

    final isMobile = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) ...[
            Text(
              'Security & Privacy Engine',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Offline-first vault protection & Privacy',
              style: TextStyle(
                fontSize: 13,
                color:
                    theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
              ),
            ),
          ] else ...[
            Text(
              'Security & Privacy Engine',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Offline-first vault protection, local PIN/Biometric authentication, and Privacy Mode',
              style: TextStyle(
                fontSize: 14,
                color:
                    theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Application Lock & Authentication Card
          MonetraCard(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Authentication & Application Lock',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color)),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Enable Application Lock'),
                  subtitle: const Text(
                      'Require PIN or Biometric unlock on app launch'),
                  value: config.isAppLockEnabled,
                  onChanged: (val) {
                    if (val && config.pinHash == null) {
                      _showSetPinDialog(context);
                    } else {
                      ref.read(securityConfigProvider.notifier).state =
                          config.copyWith(isAppLockEnabled: val);
                    }
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.password_rounded),
                  title: const Text('Change PIN Code'),
                  subtitle: Text(config.pinHash != null
                      ? '4-Digit PIN configured'
                      : 'No PIN set'),
                  trailing: ElevatedButton(
                    onPressed: () => _showSetPinDialog(context),
                    child: const Text('Configure PIN'),
                  ),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Enable Biometric Authentication'),
                  subtitle: const Text(
                      'Use Fingerprint or Face Unlock where available'),
                  value: config.isBiometricsEnabled,
                  onChanged: (val) => ref
                      .read(securityConfigProvider.notifier)
                      .state = config.copyWith(isBiometricsEnabled: val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Privacy Mode & Auto-Lock Card
          MonetraCard(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Privacy Mode & Session Management',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color)),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Enable Privacy Mode'),
                  subtitle: const Text(
                      'Mask all financial balance figures across dashboard and lists with ••••••'),
                  value: config.isPrivacyModeEnabled,
                  onChanged: (val) => ref
                      .read(securityConfigProvider.notifier)
                      .state = config.copyWith(isPrivacyModeEnabled: val),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.timer_outlined),
                  title: const Text('Auto-Lock Timeout'),
                  subtitle: const Text(
                      'Automatically lock vault when app remains idle'),
                  trailing: DropdownButton<AutoLockTimeout>(
                    value: config.autoLockTimeout,
                    items: const [
                      DropdownMenuItem(
                          value: AutoLockTimeout.immediate,
                          child: Text('Immediate')),
                      DropdownMenuItem(
                          value: AutoLockTimeout.oneMinute,
                          child: Text('1 Minute')),
                      DropdownMenuItem(
                          value: AutoLockTimeout.fiveMinutes,
                          child: Text('5 Minutes')),
                      DropdownMenuItem(
                          value: AutoLockTimeout.fifteenMinutes,
                          child: Text('15 Minutes')),
                      DropdownMenuItem(
                          value: AutoLockTimeout.never, child: Text('Never')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(securityConfigProvider.notifier).state =
                            config.copyWith(autoLockTimeout: val);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
