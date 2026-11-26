import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_stock_mobile/exceptions/login_exceptions.dart';
import 'package:i_stock_mobile/models/login_credentials.dart';
import 'package:i_stock_mobile/models/login_session.dart';
import 'package:i_stock_mobile/repositories/login_repository.dart';
import 'package:i_stock_mobile/states/login_state.dart';

import '../helpers/auth_fakes.dart';

class FakeLoginRepository implements LoginRepository {
  FakeLoginRepository(this.authenticate);

  final Future<LoginSession> Function(LoginCredentials) authenticate;
  int calls = 0;
  LoginCredentials? lastCredentials;

  @override
  Future<LoginSession> login(LoginCredentials credentials) {
    calls++;
    lastCredentials = credentials;
    return authenticate(credentials);
  }
}

void main() {
  test('starts with an empty initial state', () async {
    final cubit = makeLoginCubit(
      FakeLoginRepository((_) => throw StateError('unexpected')),
    );
    addTearDown(cubit.close);

    expect(cubit.state, isA<LoginInitial>());
    expect(cubit.state.email, isEmpty);
    expect(cubit.state.password, isEmpty);
    expect(cubit.state.isPasswordVisible, isFalse);
  });

  test('updates form values and toggles password visibility', () async {
    final cubit = makeLoginCubit(
      FakeLoginRepository((_) => throw StateError('unexpected')),
    );
    addTearDown(cubit.close);

    cubit.emailChanged('user@example.com');
    cubit.passwordChanged('secret');
    cubit.togglePasswordVisibility();

    expect(cubit.state, isA<LoginInitial>());
    expect(cubit.state.email, 'user@example.com');
    expect(cubit.state.password, 'secret');
    expect(cubit.state.isPasswordVisible, isTrue);
    cubit.togglePasswordVisibility();
    expect(cubit.state.isPasswordVisible, isFalse);
  });

  test('rejects empty fields without calling the repository', () async {
    final repository = FakeLoginRepository(
      (_) => throw StateError('unexpected'),
    );
    final cubit = makeLoginCubit(repository);
    addTearDown(cubit.close);

    await cubit.submit();

    final error = cubit.state as LoginError;
    expect(error.emailError, 'Informe seu e-mail.');
    expect(error.passwordError, 'Informe sua senha.');
    expect(repository.calls, 0);

    cubit.emailChanged('   ');
    cubit.passwordChanged('secret');
    await cubit.submit();
    final whitespaceError = cubit.state as LoginError;
    expect(whitespaceError.emailError, 'Informe seu e-mail.');
    expect(whitespaceError.passwordError, isNull);
    expect(repository.calls, 0);
  });

  test('editing after a field error restores initial state', () async {
    final cubit = makeLoginCubit(
      FakeLoginRepository((_) => throw StateError('unexpected')),
    );
    addTearDown(cubit.close);
    await cubit.submit();
    expect(cubit.state, isA<LoginError>());

    cubit.emailChanged('user@example.com');

    expect(cubit.state, isA<LoginInitial>());
    expect(cubit.state.email, 'user@example.com');
  });

  test(
    'emits loading then loaded, ignores duplicate submits, and clears password',
    () async {
      final pending = Completer<LoginSession>();
      final repository = FakeLoginRepository((_) => pending.future);
      final cubit = makeLoginCubit(repository);
      addTearDown(cubit.close);
      cubit.emailChanged('user@example.com');
      cubit.passwordChanged('secret');

      final firstSubmit = cubit.submit();
      expect(cubit.state, isA<LoginLoading>());
      await cubit.submit();
      cubit.emailChanged('changed@example.com');
      expect(repository.calls, 1);
      expect(repository.lastCredentials?.email, 'user@example.com');
      expect(repository.lastCredentials?.password, 'secret');
      expect(cubit.state.email, 'user@example.com');

      pending.complete(
        const LoginSession(accessToken: 'jwt', tokenType: 'Bearer'),
      );
      await firstSubmit;
      final loaded = cubit.state as LoginLoaded;
      expect(loaded.session.accessToken, 'jwt');
      expect(loaded.password, isEmpty);
      await cubit.signOut();
      expect(cubit.state, isA<LoginInitial>());
      expect(cubit.state.email, isEmpty);
    },
  );

  test('keeps credentials and gives a specific message for 401', () async {
    final cubit = makeLoginCubit(
      FakeLoginRepository(
        (_) async => throw const LoginInvalidCredentialsException(),
      ),
    );
    addTearDown(cubit.close);
    cubit.emailChanged('user@example.com');
    cubit.passwordChanged('wrong');

    await cubit.submit();

    final error = cubit.state as LoginError;
    expect(error.message, 'E-mail ou senha inválidos.');
    expect(error.email, 'user@example.com');
    expect(error.password, 'wrong');
  });

  test('gives a generic message for request failures', () async {
    final cubit = makeLoginCubit(
      FakeLoginRepository((_) async => throw const LoginRequestException()),
    );
    addTearDown(cubit.close);
    cubit.emailChanged('user@example.com');
    cubit.passwordChanged('secret');

    await cubit.submit();

    final error = cubit.state as LoginError;
    expect(error.message, 'Não foi possível entrar. Tente novamente.');
    expect(error.password, 'secret');
  });

  test('signing out during a request prevents a late success', () async {
    final pending = Completer<LoginSession>();
    final cubit = makeLoginCubit(FakeLoginRepository((_) => pending.future));
    addTearDown(cubit.close);
    cubit.emailChanged('user@example.com');
    cubit.passwordChanged('secret');
    final submission = cubit.submit();

    await cubit.signOut();
    pending.complete(
      const LoginSession(accessToken: 'jwt', tokenType: 'Bearer'),
    );
    await submission;

    expect(cubit.state, isA<LoginInitial>());
    expect(cubit.state.email, isEmpty);
  });

  test('signing out during a request prevents a late error', () async {
    final pending = Completer<LoginSession>();
    final cubit = makeLoginCubit(FakeLoginRepository((_) => pending.future));
    addTearDown(cubit.close);
    cubit.emailChanged('user@example.com');
    cubit.passwordChanged('secret');
    final submission = cubit.submit();

    await cubit.signOut();
    pending.completeError(const LoginRequestException());
    await submission;

    expect(cubit.state, isA<LoginInitial>());
  });
}
