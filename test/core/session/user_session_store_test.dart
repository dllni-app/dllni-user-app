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
    UserSessionStore.reload();
  });

  group('UserSessionStore', () {
    test('read returns null when no user is stored', () {
      expect(UserSessionStore.read(), isNull);
      expect(UserSessionStore.displayName(), isNull);
      expect(UserSessionStore.phone, isNull);
      expect(UserSessionStore.userNotifier.value, isNull);
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
      expect(UserSessionStore.displayName(), 'سارة أحمد');
      expect(UserSessionStore.phone, '+963912345678');
      expect(UserSessionStore.userNotifier.value?.name, 'سارة أحمد');
    });

    test('clearUserProfile removes stored user and mirrored fields but keeps token', () async {
      await SharedPreferencesHelper.saveData(
        key: UserSessionKeys.token,
        value: 'session-token',
      );
      await UserSessionStore.writeAndMirror(
        LoggedInUserModel(name: 'Temp User', phone: '+963900000000'),
      );

      await UserSessionStore.clearUserProfile();

      expect(UserSessionStore.read(), isNull);
      expect(UserSessionStore.userNotifier.value, isNull);
      expect(
        SharedPreferencesHelper.getData(key: UserSessionKeys.loggedInUser),
        isNull,
      );
      expect(
        SharedPreferencesHelper.getData(key: UserSessionKeys.customerName),
        isNull,
      );
      expect(
        SharedPreferencesHelper.getData(key: UserSessionKeys.token),
        'session-token',
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

    test('saveLoginResponse stores token, customer id, user, and mirrored fields', () async {
      await UserSessionStore.saveLoginResponse(
        LoginResponseModel(
          token: 'abc123',
          data: LoggedInUserModel(
            id: 42,
            name: 'Ali',
            phone: '+963933333333',
          ),
        ),
      );

      expect(
        SharedPreferencesHelper.getData(key: UserSessionKeys.token),
        'abc123',
      );
      expect(
        SharedPreferencesHelper.getData(key: UserSessionKeys.customerId),
        42,
      );
      expect(UserSessionStore.read()?.name, 'Ali');
      expect(
        SharedPreferencesHelper.getData(key: UserSessionKeys.customerName),
        'Ali',
      );
      expect(UserSessionStore.userNotifier.value?.id, 42);
    });

    test('reload rehydrates notifier from shared preferences', () async {
      await UserSessionStore.write(LoggedInUserModel(name: 'Reload Me'));
      UserSessionStore.userNotifier.value = null;

      UserSessionStore.reload();

      expect(UserSessionStore.userNotifier.value?.name, 'Reload Me');
    });

    test('displayNameOrPlaceholder returns placeholder only for blank names', () async {
      expect(
        UserSessionStore.displayNameOrPlaceholder(),
        UserSessionStore.defaultDisplayNamePlaceholder,
      );

      await UserSessionStore.write(LoggedInUserModel(name: '   '));
      expect(
        UserSessionStore.displayNameOrPlaceholder(),
        UserSessionStore.defaultDisplayNamePlaceholder,
      );

      await UserSessionStore.write(LoggedInUserModel(name: 'Karim'));
      expect(UserSessionStore.displayNameOrPlaceholder(), 'Karim');
    });
  });
}
