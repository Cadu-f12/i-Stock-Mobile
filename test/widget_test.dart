import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_stock_mobile/cubits/login_cubit.dart';
import 'package:i_stock_mobile/exceptions/login_exceptions.dart';
import 'package:i_stock_mobile/main.dart';
import 'package:i_stock_mobile/models/login_credentials.dart';
import 'package:i_stock_mobile/models/login_session.dart';
import 'package:i_stock_mobile/models/stored_session.dart';
import 'package:i_stock_mobile/repositories/login_repository.dart';
import 'package:i_stock_mobile/views/login_page.dart';

import 'helpers/auth_fakes.dart';

class FakeLoginRepository implements LoginRepository {
  FakeLoginRepository(this.authenticate);

  final Future<LoginSession> Function(LoginCredentials) authenticate;

  @override
  Future<LoginSession> login(LoginCredentials credentials) =>
      authenticate(credentials);
}

Future<void> showLogin(
  WidgetTester tester,
  LoginRepository repository, {
  FakeSessionStore? store,
  FakeDeviceAuthenticator? authenticator,
  DateTime Function()? now,
}) async {
  await tester.pumpWidget(
    BlocProvider<LoginCubit>(
      create: (_) => makeLoginCubit(
        repository,
        store: store,
        authenticator: authenticator,
        now: now,
      ),
      child: const MaterialApp(home: LoginPage()),
    ),
  );
}

void main() {
  testWidgets('loads env asset and opens login', (tester) async {
    await dotenv.load(fileName: '.env');
    await tester.pumpWidget(const MyApp());

    expect(find.text('Acesse sua conta'), findsOneWidget);
    expect(find.text('Desbloquear com biometria'), findsOneWidget);
  });

  testWidgets('shows field errors for empty credentials', (tester) async {
    await showLogin(
      tester,
      FakeLoginRepository((_) => throw StateError('unexpected')),
    );

    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(find.text('Informe seu e-mail.'), findsOneWidget);
    expect(find.text('Informe sua senha.'), findsOneWidget);
  });

  testWidgets('password visibility follows the Cubit state', (tester) async {
    await showLogin(
      tester,
      FakeLoginRepository((_) => throw StateError('unexpected')),
    );
    await tester.enterText(find.byType(TextField).at(1), 'secret');
    expect(
      tester.widget<TextField>(find.byType(TextField).at(1)).obscureText,
      isTrue,
    );

    await tester.tap(find.byTooltip('Mostrar senha'));
    await tester.pump();

    expect(
      tester.widget<TextField>(find.byType(TextField).at(1)).obscureText,
      isFalse,
    );
    expect(find.text('secret'), findsOneWidget);
  });

  testWidgets('shows loading and opens placeholder after success', (
    tester,
  ) async {
    final pending = Completer<LoginSession>();
    await showLogin(tester, FakeLoginRepository((_) => pending.future));

    await tester.enterText(find.byType(TextField).at(0), 'user@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'secret');
    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    pending.complete(
      const LoginSession(accessToken: 'token', tokenType: 'Bearer'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Pastilles — próxima etapa'), findsOneWidget);

    await tester.tap(find.byTooltip('Sair'));
    await tester.pumpAndSettle();
    expect(find.text('Acesse sua conta'), findsOneWidget);
  });

  testWidgets('shows invalid credentials returned by repository', (
    tester,
  ) async {
    await showLogin(
      tester,
      FakeLoginRepository(
        (_) async => throw const LoginInvalidCredentialsException(),
      ),
    );

    await tester.enterText(find.byType(TextField).at(0), 'user@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'wrong');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('E-mail ou senha inválidos.'), findsOneWidget);
    expect(find.text('wrong'), findsOneWidget);
  });

  testWidgets('shows an error when the API URL is not configured', (
    tester,
  ) async {
    final repository = LoginRepositoryImpl(baseUri: Uri());
    addTearDown(repository.close);
    await showLogin(tester, repository);

    await tester.enterText(find.byType(TextField).at(0), 'user@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'secret');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(
      find.text('Não foi possível entrar. Tente novamente.'),
      findsOneWidget,
    );
  });

  testWidgets('offers opt-in after password login and clears it on sign-out', (
    tester,
  ) async {
    final now = DateTime.utc(2026, 11, 26, 12);
    final store = FakeSessionStore();
    final auth = FakeDeviceAuthenticator()..enrolled = true;
    await showLogin(
      tester,
      FakeLoginRepository(
        (_) async =>
            const LoginSession(accessToken: 'token', tokenType: 'Bearer'),
      ),
      store: store,
      authenticator: auth,
      now: () => now,
    );

    await tester.enterText(find.byType(TextField).at(0), 'user@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'secret');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(find.text('Ativar desbloqueio?'), findsOneWidget);
    await tester.tap(find.text('Ativar agora'));
    await tester.pumpAndSettle();
    expect(store.saved?.session.accessToken, 'token');
    expect(find.text('Pastilles — próxima etapa'), findsOneWidget);
    await tester.tap(find.byTooltip('Bloquear'));
    await tester.pumpAndSettle();
    expect(store.saved, isNotNull);
    expect(find.text('Desbloquear com biometria'), findsOneWidget);
    await tester.ensureVisible(find.text('Desbloquear com biometria'));
    await tester.tap(find.text('Desbloquear com biometria'));
    await tester.pumpAndSettle();
    expect(auth.prompts, 1);
    expect(find.text('Pastilles — próxima etapa'), findsOneWidget);
    await tester.tap(find.byTooltip('Sair'));
    await tester.pumpAndSettle();
    expect(store.saved, isNull);
    expect(find.text('Acesse sua conta'), findsOneWidget);
    expect(find.text('Desbloquear com biometria'), findsOneWidget);
  });

  testWidgets('saved session shows unlock action and opens Pastilles', (
    tester,
  ) async {
    final now = DateTime.utc(2026, 11, 26, 12);
    final store = FakeSessionStore()
      ..saved = StoredSession(
        const LoginSession(accessToken: 'saved', tokenType: 'Bearer'),
        now.add(const Duration(minutes: 10)),
      );
    final auth = FakeDeviceAuthenticator()..enrolled = true;
    await showLogin(
      tester,
      FakeLoginRepository((_) => throw StateError('unexpected')),
      store: store,
      authenticator: auth,
      now: () => now,
    );
    await tester.pumpAndSettle();
    expect(find.text('Desbloquear com biometria'), findsOneWidget);
    await tester.ensureVisible(find.text('Desbloquear com biometria'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Desbloquear com biometria'));
    await tester.pumpAndSettle();
    expect(auth.prompts, 1);
    expect(find.text('Pastilles — próxima etapa'), findsOneWidget);
  });
}
