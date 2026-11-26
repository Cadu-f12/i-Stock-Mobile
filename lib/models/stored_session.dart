import 'dart:convert';

import 'package:i_stock_mobile/models/login_session.dart';

class StoredSession {
  const StoredSession(this.session, this.expiresAt);

  final LoginSession session;
  final DateTime expiresAt;

  bool isValidAt(DateTime time) => time.isBefore(expiresAt);

  /// The request start is a conservative cap when the JWT has no usable exp.
  static DateTime deadline(String token, DateTime requestStartedAt) {
    final cap = requestStartedAt.toUtc().add(const Duration(minutes: 15));
    try {
      final parts = token.split('.');
      if (parts.length != 3) return cap;
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      if (payload is! Map<String, dynamic> || payload['exp'] is! num) {
        return cap;
      }
      final exp = DateTime.fromMillisecondsSinceEpoch(
        ((payload['exp'] as num) * 1000).toInt(),
        isUtc: true,
      );
      return exp.isBefore(cap) ? exp : cap;
    } catch (_) {
      return cap;
    }
  }
}
