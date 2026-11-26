import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:i_stock_mobile/models/login_session.dart';
import 'package:i_stock_mobile/models/stored_session.dart';

abstract interface class SessionStore {
  Future<DateTime?> readExpiry();
  Future<StoredSession?> readSession();
  Future<void> save(StoredSession session);
  Future<void> clear();
}

class SecureSessionStore implements SessionStore {
  SecureSessionStore(this._storage);

  final FlutterSecureStorage _storage;
  static const _tokenKey = 'istock_access_token';
  static const _typeKey = 'istock_token_type';
  static const _expiryKey = 'istock_token_expiry';

  @override
  Future<DateTime?> readExpiry() async {
    final raw = await _storage.read(key: _expiryKey);
    return raw == null ? null : DateTime.tryParse(raw)?.toUtc();
  }

  @override
  Future<StoredSession?> readSession() async {
    final token = await _storage.read(key: _tokenKey);
    final type = await _storage.read(key: _typeKey);
    final expiry = await readExpiry();
    if (token == null || type == null || expiry == null) return null;
    return StoredSession(
      LoginSession(accessToken: token, tokenType: type),
      expiry,
    );
  }

  @override
  Future<void> save(StoredSession session) async {
    await _storage.write(key: _tokenKey, value: session.session.accessToken);
    await _storage.write(key: _typeKey, value: session.session.tokenType);
    await _storage.write(
      key: _expiryKey,
      value: session.expiresAt.toUtc().toIso8601String(),
    );
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _expiryKey);
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _typeKey);
  }
}
