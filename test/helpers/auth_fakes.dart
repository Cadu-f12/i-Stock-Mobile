import 'package:i_stock_mobile/cubits/login_cubit.dart';
import 'package:i_stock_mobile/models/stored_session.dart';
import 'package:i_stock_mobile/repositories/device_authenticator.dart';
import 'package:i_stock_mobile/repositories/login_repository.dart';
import 'package:i_stock_mobile/repositories/session_store.dart';

class FakeSessionStore implements SessionStore {
  StoredSession? saved;
  int sessionReads = 0;

  @override
  Future<DateTime?> readExpiry() async => saved?.expiresAt;

  @override
  Future<StoredSession?> readSession() async {
    sessionReads++;
    return saved;
  }

  @override
  Future<void> save(StoredSession session) async {
    saved = session;
  }

  @override
  Future<void> clear() async {
    saved = null;
  }
}

class FakeDeviceAuthenticator implements DeviceAuthenticator {
  bool enrolled = false;
  DeviceAuthResult result = DeviceAuthResult.authenticated;
  int prompts = 0;

  @override
  Future<bool> hasEnrolledBiometrics() async => enrolled;

  @override
  Future<DeviceAuthResult> authenticate() async {
    prompts++;
    return result;
  }
}

LoginCubit makeLoginCubit(
  LoginRepository repository, {
  FakeSessionStore? store,
  FakeDeviceAuthenticator? authenticator,
  DateTime Function()? now,
}) => LoginCubit(
  repository,
  store ?? FakeSessionStore(),
  authenticator ?? FakeDeviceAuthenticator(),
  now: now,
);
