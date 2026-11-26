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
import 'package:i_stock_mobile/repositories/login_repository.dart';
import 'package:i_stock_mobile/views/login_page.dart';

class FakeLoginRepository implements LoginRepository {
  FakeLoginRepository(this.authenticate);

  final Future<LoginSession> Function(LoginCredentials) authenticate;

  @override
  Future<LoginSession> login(LoginCredentials credentials) =>
      authenticate(credentials);
}

Future<void> showLogin(WidgetTester tester, LoginRepository repository) async {
  await tester.pumpWidget(
    BlocProvider<LoginCubit>(
      create: (_) => LoginCubit(repository),
      child: const MaterialApp(home: LoginPage()),
    ),
  );
}

void main() {
  testWidgets('loads env asset and opens login', (tester) async {
    await dotenv.load(fileName: '.env');
    await tester.pumpWidget(const MyApp());

    expect(find.text('Acesse sua conta'), findsOneWidget);
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
}
