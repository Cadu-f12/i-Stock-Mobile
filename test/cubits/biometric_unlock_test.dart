import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_stock_mobile/models/login_credentials.dart';
import 'package:i_stock_mobile/models/login_session.dart';
import 'package:i_stock_mobile/models/stored_session.dart';
import 'package:i_stock_mobile/repositories/device_authenticator.dart';
import 'package:i_stock_mobile/repositories/login_repository.dart';
import 'package:i_stock_mobile/states/login_state.dart';

import '../helpers/auth_fakes.dart';

class LoginSuccess implements LoginRepository {
  @override
  Future<LoginSession> login(LoginCredentials credentials) async =>
      const LoginSession(accessToken: 'token', tokenType: 'Bearer');
}

void main() {
  final start = DateTime.utc(2026, 11, 26, 12);

  test('opt-in saves the session only with enrolled biometrics', () async {
    final store = FakeSessionStore();
    final auth = FakeDeviceAuthenticator();
    final cubit = makeLoginCubit(
      LoginSuccess(),
      store: store,
      authenticator: auth,
      now: () => start,
    );
    addTearDown(cubit.close);
    cubit.emailChanged('user@example.com');
    cubit.passwordChanged('secret');
    await cubit.submit();
    expect(cubit.state, isA<LoginLoaded>());
    expect(await cubit.enableBiometrics(), isFalse);
    expect(store.saved, isNull);
    auth.enrolled = true;
    expect(await cubit.enableBiometrics(), isTrue);
    expect(store.saved?.expiresAt, start.add(const Duration(minutes: 15)));
    expect(store.saved?.session.accessToken, 'token');
  });

  test(
    'locking keeps the opted-in session available for the next unlock',
    () async {
      final store = FakeSessionStore();
      final auth = FakeDeviceAuthenticator()..enrolled = true;
      final cubit = makeLoginCubit(
        LoginSuccess(),
        store: store,
        authenticator: auth,
        now: () => start,
      );
      addTearDown(cubit.close);
      cubit.emailChanged('user@example.com');
      cubit.passwordChanged('secret');
      await cubit.submit();
      expect(await cubit.enableBiometrics(), isTrue);

      cubit.lock();
      expect(cubit.state, isA<LoginInitial>());
      expect(store.saved, isNotNull);
      await cubit.initialize();
      expect(cubit.state.canUnlock, isTrue);
      await cubit.unlockWithBiometrics();
      expect((cubit.state as LoginLoaded).fromBiometrics, isTrue);
      expect(auth.prompts, 1);
    },
  );

  test(
    'tapping unlock without a saved session explains the next step',
    () async {
      final auth = FakeDeviceAuthenticator()..enrolled = true;
      final cubit = makeLoginCubit(
        LoginSuccess(),
        authenticator: auth,
        now: () => start,
      );
      addTearDown(cubit.close);
      await cubit.unlockWithBiometrics();
      expect(cubit.state.statusMessage, contains('Entre com e-mail e senha'));
      expect(auth.prompts, 0);
    },
  );

  test(
    'saved token is read only after local authentication succeeds',
    () async {
      final store = FakeSessionStore()
        ..saved = StoredSession(
          const LoginSession(accessToken: 'saved', tokenType: 'Bearer'),
          start.add(const Duration(minutes: 15)),
        );
      final auth = FakeDeviceAuthenticator()..enrolled = true;
      final cubit = makeLoginCubit(
        LoginSuccess(),
        store: store,
        authenticator: auth,
        now: () => start,
      );
      addTearDown(cubit.close);
      await cubit.initialize();
      expect(cubit.state.canUnlock, isTrue);
      expect(store.sessionReads, 0);
      cubit.emailChanged('user@example.com');
      cubit.passwordChanged('typed-password');
      auth.result = DeviceAuthResult.cancelled;
      await cubit.unlockWithBiometrics();
      expect(store.sessionReads, 0);
      expect(cubit.state, isA<LoginInitial>());
      expect(cubit.state.password, 'typed-password');
      auth.result = DeviceAuthResult.authenticated;
      await cubit.unlockWithBiometrics();
      expect(store.sessionReads, 1);
      expect((cubit.state as LoginLoaded).fromBiometrics, isTrue);
      expect(cubit.state.email, isEmpty);
      expect(auth.prompts, 2);
    },
  );

  test('expired session is removed before prompting', () async {
    final store = FakeSessionStore()
      ..saved = StoredSession(
        const LoginSession(accessToken: 'old', tokenType: 'Bearer'),
        start,
      );
    final auth = FakeDeviceAuthenticator()..enrolled = true;
    final cubit = makeLoginCubit(
      LoginSuccess(),
      store: store,
      authenticator: auth,
      now: () => start,
    );
    addTearDown(cubit.close);
    await cubit.initialize();
    expect(store.saved, isNull);
    expect(cubit.state.canUnlock, isFalse);
    expect(cubit.state.statusMessage, contains('expirou'));
    expect(auth.prompts, 0);
  });

  test(
    'saved session without enrolled biometrics keeps password login',
    () async {
      final store = FakeSessionStore()
        ..saved = StoredSession(
          const LoginSession(accessToken: 'saved', tokenType: 'Bearer'),
          start.add(const Duration(minutes: 10)),
        );
      final cubit = makeLoginCubit(
        LoginSuccess(),
        store: store,
        now: () => start,
      );
      addTearDown(cubit.close);
      await cubit.initialize();
      expect(cubit.state.canUnlock, isFalse);
      expect(cubit.state.statusMessage, contains('indisponível'));
      expect(store.saved, isNotNull);
    },
  );

  test('sign-out deletes the saved token', () async {
    final store = FakeSessionStore()
      ..saved = StoredSession(
        const LoginSession(accessToken: 'saved', tokenType: 'Bearer'),
        start.add(const Duration(minutes: 15)),
      );
    final cubit = makeLoginCubit(
      LoginSuccess(),
      store: store,
      now: () => start,
    );
    addTearDown(cubit.close);
    await cubit.signOut();
    expect(store.saved, isNull);
    expect(cubit.state, isA<LoginInitial>());
  });

  test('local deadline never exceeds fifteen minutes', () {
    expect(
      StoredSession.deadline('opaque', start),
      start.add(const Duration(minutes: 15)),
    );
  });

  test('earlier JWT expiration shortens the local deadline', () {
    final exp = start.add(const Duration(minutes: 4));
    final payload = base64Url.encode(
      utf8.encode(jsonEncode({'exp': exp.millisecondsSinceEpoch ~/ 1000})),
    );
    expect(StoredSession.deadline('header.$payload.signature', start), exp);
  });
}
