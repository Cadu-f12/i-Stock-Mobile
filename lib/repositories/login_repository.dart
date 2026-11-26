import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:i_stock_mobile/exceptions/login_exceptions.dart';
import 'package:i_stock_mobile/models/login_credentials.dart';
import 'package:i_stock_mobile/models/login_session.dart';

/// Contract for authenticating with the I-STOCK identity service.
///
/// Implementations will be added once the API integration is in scope.
abstract interface class LoginRepository {
  static const String loginRoute = '/api/public/auth/login';

  Future<LoginSession> login(LoginCredentials credentials);
}

class LoginRepositoryImpl implements LoginRepository {
  LoginRepositoryImpl({required this.baseUri, http.Client? client})
    : _client = client ?? http.Client(),
      _ownsClient = client == null;

  final Uri baseUri;
  final http.Client _client;
  final bool _ownsClient;

  @override
  Future<LoginSession> login(LoginCredentials credentials) async {
    final response = await _client.post(
      baseUri.resolve(LoginRepository.loginRoute),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': credentials.email,
        'password': credentials.password,
      }),
    );

    if (response.statusCode == 401) {
      throw const LoginInvalidCredentialsException();
    }
    if (response.statusCode != 200) {
      throw const LoginRequestException();
    }

    final dynamic payload;
    try {
      payload = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const LoginResponseException();
    }

    if (payload is! Map<String, dynamic> ||
        payload['accessToken'] is! String ||
        payload['tokenType'] is! String) {
      throw const LoginResponseException();
    }

    return LoginSession(
      accessToken: payload['accessToken'] as String,
      tokenType: payload['tokenType'] as String,
    );
  }

  void close() {
    if (_ownsClient) _client.close();
  }
}
