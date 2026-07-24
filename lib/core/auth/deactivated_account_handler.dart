import 'package:common_package/common_package.dart';

import '../session/user_session_keys.dart';
import '../session/user_session_store.dart';
import 'auth_gate.dart';

abstract final class DeactivatedAccountHandler {
  static const String errorCode = 'ACCOUNT_NOT_ACTIVE';

  static Future<void> clearSession() async {
    await SharedPreferencesHelper.removeData(key: UserSessionKeys.token);
    await UserSessionStore.clear();
    AuthGate.clearPendingAction();
  }
}
