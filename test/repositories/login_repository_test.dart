import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:i_stock_mobile/exceptions/login_exceptions.dart';
import 'package:i_stock_mobile/models/login_credentials.dart';
import 'package:i_stock_mobile/repositories/login_repository.dart';

const credentials = LoginCredentials(
  email: 'user@example.com',
  password: 'secret',
);
final baseUri = Uri.parse('http://localhost:8080/');

void main() {
  test('posts JSON credentials to the Swagger login route', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(
        request.url.toString(),
        'http://localhost:8080/api/public/auth/login',
      );
      expect(request.headers['content-type'], 'application/json');
      expect(request.headers['accept'], 'application/json');
      expect(jsonDecode(request.body), {
        'email': 'user@example.com',
        'password': 'secret',
      });
      return http.Response(
        jsonEncode({'accessToken': 'jwt', 'tokenType': 'Bearer'}),
        200,
      );
    });
    addTearDown(client.close);
    final repository = LoginRepositoryImpl(baseUri: baseUri, client: client);

    final session = await repository.login(credentials);

    expect(session.accessToken, 'jwt');
    expect(session.tokenType, 'Bearer');
  });

  test('maps HTTP 401 to invalid credentials', () async {
    final client = MockClient((_) async => http.Response('{}', 401));
    addTearDown(client.close);
    final repository = LoginRepositoryImpl(baseUri: baseUri, client: client);

    await expectLater(
      repository.login(credentials),
      throwsA(isA<LoginInvalidCredentialsException>()),
    );
  });

  test('maps non-success HTTP statuses to request errors', () async {
    final client = MockClient((_) async => http.Response('unavailable', 503));
    addTearDown(client.close);
    final repository = LoginRepositoryImpl(baseUri: baseUri, client: client);

    await expectLater(
      repository.login(credentials),
      throwsA(isA<LoginRequestException>()),
    );
  });

  test('rejects malformed and incomplete success responses', () async {
    for (final body in ['not JSON', '[]', '{}', '{"accessToken":"jwt"}']) {
      final client = MockClient((_) async => http.Response(body, 200));
      final repository = LoginRepositoryImpl(baseUri: baseUri, client: client);
      await expectLater(
        repository.login(credentials),
        throwsA(isA<LoginResponseException>()),
      );
      client.close();
    }
  });

  test('rejects a missing API base URL without sending a request', () async {
    var called = false;
    final client = MockClient((_) async {
      called = true;
      return http.Response('{}', 200);
    });
    addTearDown(client.close);
    final repository = LoginRepositoryImpl(baseUri: Uri(), client: client);

    await expectLater(
      repository.login(credentials),
      throwsA(isA<LoginRequestException>()),
    );
    expect(called, isFalse);
  });
}
