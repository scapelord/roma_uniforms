import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final _auth = LocalAuthentication();

  // 1. Check if hardware is available
  static Future<bool> isDeviceSupported() async {
    try {
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      return canCheckBiometrics && isDeviceSupported;
    } on PlatformException catch (_) {
      return false;
    }
  }

  // 2. Perform the Scan
  static Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Scan fingerprint to access Race Control',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (_) {
      return false;
    }
  }
}
