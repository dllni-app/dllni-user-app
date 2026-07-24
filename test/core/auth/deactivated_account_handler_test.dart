import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/auth/deactivated_account_handler.dart';
import 'package:dllni_user_app/core/session/user_session_keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      UserSessionKeys.token: 'stale-token',
      UserSessionKeys.customerId: 10,
      UserSessionKeys.customerName: 'مستخدم تجريبي',
      UserSessionKeys.customerEmail: 'user@example.com',
      UserSessionKeys.customerPhone: '+963944000000',
      UserSessionKeys.loggedInUser: '{"id":10,"name":"مستخدم تجريبي"}',
    });
    await SharedPreferencesHelper.init();
  });

  test('clears stored authentication and user session data', () async {
    await DeactivatedAccountHandler.clearSession();

    expect(
      SharedPreferencesHelper.getData(key: UserSessionKeys.token),
      isNull,
    );
    expect(
      SharedPreferencesHelper.getData(key: UserSessionKeys.customerId),
      isNull,
    );
    expect(
      SharedPreferencesHelper.getData(key: UserSessionKeys.customerName),
      isNull,
    );
    expect(
      SharedPreferencesHelper.getData(key: UserSessionKeys.customerEmail),
      isNull,
    );
    expect(
      SharedPreferencesHelper.getData(key: UserSessionKeys.customerPhone),
      isNull,
    );
    expect(
      SharedPreferencesHelper.getData(key: UserSessionKeys.loggedInUser),
      isNull,
    );
  });
}
