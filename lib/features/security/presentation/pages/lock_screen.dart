import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monetra/features/security/presentation/providers/security_providers.dart';
import 'package:monetra/features/security/services/security_services.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String _enteredPin = '';
  String? _errorMessage;

  void _onKeyPress(String digit) {
    final config = ref.read(securityConfigProvider);
    if (_enteredPin.length < config.pinLength) {
      setState(() {
        _enteredPin += digit;
        _errorMessage = null;
      });

      if (_enteredPin.length == config.pinLength) {
        _verifyEnteredPin();
      }
    }
  }

  void _onDelete() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _errorMessage = null;
      });
    }
  }

  void _verifyEnteredPin() {
    final config = ref.read(securityConfigProvider);
    if (config.pinHash == null ||
        PinHasher.verifyPin(_enteredPin, config.pinHash!)) {
      ref.read(sessionStateProvider.notifier).state =
          ref.read(sessionStateProvider).copyWith(
                isLocked: false,
                lastActiveTimestamp: DateTime.now(),
                failedAttempts: 0,
              );
    } else {
      final currentFailed = ref.read(sessionStateProvider).failedAttempts + 1;
      ref.read(sessionStateProvider.notifier).state = ref
          .read(sessionStateProvider)
          .copyWith(failedAttempts: currentFailed);
      setState(() {
        _enteredPin = '';
        _errorMessage = 'Incorrect PIN. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = ref.watch(securityConfigProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Container(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.lock_rounded,
                      size: 48, color: theme.colorScheme.primary),
                ),
                const SizedBox(height: 24),
                Text(
                  'Monetra Vault Locked',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your PIN to access your financial records',
                  style: TextStyle(
                      fontSize: 13,
                      color: theme.textTheme.bodyMedium?.color
                          ?.withValues(alpha: 0.6)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // PIN Dot Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    config.pinLength,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index < _enteredPin.length
                            ? theme.colorScheme.primary
                            : Colors.grey.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_errorMessage != null)
                  Text(_errorMessage!,
                      style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),

                // Numeric Keypad Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: 12,
                  itemBuilder: (ctx, index) {
                    if (index == 9) {
                      return config.isBiometricsEnabled
                          ? IconButton(
                              icon: const Icon(Icons.fingerprint_rounded,
                                  size: 28),
                              onPressed: () {
                                ref.read(sessionStateProvider.notifier).state =
                                    ref.read(sessionStateProvider).copyWith(
                                          isLocked: false,
                                          lastActiveTimestamp: DateTime.now(),
                                        );
                              },
                            )
                          : const SizedBox.shrink();
                    }
                    if (index == 10) {
                      return _buildKeypadButton(context, '0');
                    }
                    if (index == 11) {
                      return IconButton(
                        icon: const Icon(Icons.backspace_outlined),
                        onPressed: _onDelete,
                      );
                    }
                    return _buildKeypadButton(context, '${index + 1}');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadButton(BuildContext context, String digit) {
    return InkWell(
      onTap: () => _onKeyPress(digit),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Text(digit,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
