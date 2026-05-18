import 'package:common_package/common_package.dart';

import 'user_session_keys.dart';

class UserSessionPrefs {
  static String? readString(String key) {
    final raw = SharedPreferencesHelper.getData(key: key);
    if (raw == null) return null;
    final value = '$raw'.trim();
    return value.isEmpty ? null : value;
  }

  static Future<void> saveUserProfile({
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    String? phoneVerifiedAt,
  }) async {
    await _saveOrRemoveString(UserSessionKeys.customerName, name);
    await _saveOrRemoveString(UserSessionKeys.customerEmail, email);
    await _saveOrRemoveString(UserSessionKeys.customerPhone, phone);
    await _saveOrRemoveString(UserSessionKeys.customerAvatarUrl, avatarUrl);
    await _saveOrRemoveString(
      UserSessionKeys.customerPhoneVerifiedAt,
      phoneVerifiedAt,
    );
  }

  static Future<void> _saveOrRemoveString(String key, String? value) async {
    final safeValue = value?.trim();
    if (safeValue == null || safeValue.isEmpty) {
      await SharedPreferencesHelper.removeData(key: key);
      return;
    }
    await SharedPreferencesHelper.saveData(key: key, value: safeValue);
  }
}
