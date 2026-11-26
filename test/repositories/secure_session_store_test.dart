import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_stock_mobile/models/login_session.dart';
import 'package:i_stock_mobile/models/stored_session.dart';
import 'package:i_stock_mobile/repositories/session_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'secure store restores a saved session and removes it on sign-out',
    () async {
      FlutterSecureStorage.setMockInitialValues({});
      final first = SecureSessionStore(const FlutterSecureStorage());
      final expiry = DateTime.utc(2026, 11, 26, 12, 15);
      await first.save(
        StoredSession(
          const LoginSession(accessToken: 'jwt', tokenType: 'Bearer'),
          expiry,
        ),
      );

      final reopened = SecureSessionStore(const FlutterSecureStorage());
      expect(await reopened.readExpiry(), expiry);
      expect((await reopened.readSession())?.session.accessToken, 'jwt');
      await reopened.clear();
      expect(await first.readExpiry(), isNull);
      expect(await first.readSession(), isNull);
    },
  );
}
