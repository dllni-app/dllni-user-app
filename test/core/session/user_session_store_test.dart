import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/session/user_session_keys.dart';
import 'package:dllni_user_app/core/session/user_session_store.dart';
import 'package:dllni_user_app/features/auth/data/models/login_response_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await SharedPreferencesHelper.init();
  });

  group('UserSessionStore', () {
    test('read returns null when no user is stored', () {
      expect(UserSessionStore.read(), isNull);
      expect(UserSessionStore.displayName, isNull);
      expect(UserSessionStore.phone, isNull);
    });

    test('write and read round-trip user model', () async {
      final user = LoggedInUserModel(
        id: 7,
        name: 'سارة أحمد',
        email: 'sara@example.com',
        phone: '+963912345678',
      );

      await UserSessionStore.write(user);

      final stored = UserSessionStore.read();
      expect(stored?.id, 7);
      expect(stored?.name, 'سارة أحمد');
      expect(stored?.email, 'sara@example.com');
      expect(stored?.phone, '+963912345678');
      expect(UserSessionStore.displayName, 'سارة أحمد');
      expect(UserSessionStore.phone, '+963912345678');
    });

    test('clear removes stored user', () async {
      await UserSessionStore.write(
        LoggedInUserModel(name: 'Temp User'),
      );

      await UserSessionStore.clear();

      expect(UserSessionStore.read(), isNull);
      expect(
        SharedPreferencesHelper.getData(key: UserSessionKeys.loggedInUser),
        isNull,
      );
    });

    test('writeAndMirror stores flat profile keys', () async {
      await UserSessionStore.writeAndMirror(
        LoggedInUserModel(
          name: 'Mustafa',
          email: 'mustafa@example.com',
          phone: '+963911111111',
          phoneVerifiedAt: '2026-01-01T00:00:00Z',
        ),
      );

      expect(UserSessionStore.read()?.name, 'Mustafa');
      expect(
        SharedPreferencesHelper.getData(key: UserSessionKeys.customerName),
        'Mustafa',
      );
      expect(
        SharedPreferencesHelper.getData(key: UserSessionKeys.customerEmail),
        'mustafa@example.com',
      );
      expect(
        SharedPreferencesHelper.getData(key: UserSessionKeys.customerPhone),
        '+963911111111',
      );
      expect(
        SharedPreferencesHelper.getData(
          key: UserSessionKeys.customerPhoneVerifiedAt,
        ),
        '2026-01-01T00:00:00Z',
      );
    });

    test('displayName ignores blank stored names', () async {
      await UserSessionStore.write(LoggedInUserModel(name: '   '));

      expect(UserSessionStore.displayName, isNull);
    });
  });
}
