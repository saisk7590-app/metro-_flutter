import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

class BiometricAuthService {
  BiometricAuthService();

  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if the device hardware supports biometrics or device credentials
  Future<bool> isDeviceSupported() async {
    if (kIsWeb) return true; // Simulated support on PC web browser
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      debugPrint('Error checking isDeviceSupported: $e');
      return false;
    }
  }

  /// Check if biometric hardware exists and is ready
  Future<bool> canCheckBiometrics() async {
    if (kIsWeb) return true; // Simulated support on PC web browser
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      debugPrint('Error checking canCheckBiometrics: $e');
      return false;
    }
  }

  /// Get list of available/enrolled biometrics (fingerprint, face, etc.)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    if (kIsWeb) {
      return <BiometricType>[BiometricType.fingerprint];
    }
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Error getting available biometrics: $e');
      return <BiometricType>[];
    }
  }

  /// Authenticate using device biometrics with fallback to PIN/Pattern/Password
  Future<bool> authenticate({
    String reason = 'Authenticate to access Hyderabad Metro AMS',
  }) async {
    // On PC browser (Chrome / Edge), simulate biometric authentication
    if (kIsWeb) {
      debugPrint('Web/PC platform detected: Simulating biometric prompt');
      await Future.delayed(const Duration(milliseconds: 700));
      return true;
    }

    try {
      final isSupported = await isDeviceSupported();
      if (!isSupported) {
        debugPrint('Biometrics not supported on this device');
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: false, // Allows Fingerprint, Face, PIN, Pattern, Password
        persistAcrossBackgrounding: false,
      );
    } catch (e) {
      debugPrint('Biometric authentication error: $e');
      return false;
    }
  }
}
