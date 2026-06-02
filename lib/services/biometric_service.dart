import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
    final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
    return canAuthenticate;
  }

  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Please authenticate to access the Admin Panel',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Biometric error: $e');
      }
      return false;
    }
  }
}
