import 'package:local_auth/local_auth.dart';

enum DeviceAuthResult { authenticated, cancelled, failed }

class BiometricsUnavailableException implements Exception {
  const BiometricsUnavailableException();
}

abstract interface class DeviceAuthenticator {
  Future<bool> hasEnrolledBiometrics();
  Future<DeviceAuthResult> authenticate();
}

class NativeDeviceAuthenticator implements DeviceAuthenticator {
  NativeDeviceAuthenticator(this._auth);

  final LocalAuthentication _auth;

  @override
  Future<bool> hasEnrolledBiometrics() async =>
      (await _auth.getAvailableBiometrics()).isNotEmpty;

  @override
  Future<DeviceAuthResult> authenticate() async {
    try {
      final accepted = await _auth.authenticate(
        localizedReason: 'Desbloqueie sua sessão do I-STOCK',
        biometricOnly: false,
      );
      return accepted
          ? DeviceAuthResult.authenticated
          : DeviceAuthResult.failed;
    } on LocalAuthException catch (error) {
      if (error.code == LocalAuthExceptionCode.userCanceled ||
          error.code == LocalAuthExceptionCode.systemCanceled) {
        return DeviceAuthResult.cancelled;
      }
      if (error.code == LocalAuthExceptionCode.noBiometricsEnrolled ||
          error.code == LocalAuthExceptionCode.noBiometricHardware ||
          error.code == LocalAuthExceptionCode.noCredentialsSet) {
        throw const BiometricsUnavailableException();
      }
      return DeviceAuthResult.failed;
    }
  }
}
