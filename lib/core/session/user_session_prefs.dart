import 'dart:convert';

import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/features/auth/data/models/login_response_model.dart';

import 'user_session_keys.dart';

class UserSessionPrefs {
  static String? readString(String key) {
    final raw = SharedPreferencesHelper.getData(key: key);
    if (raw == null) return null;
    final value = '$raw'.trim();
    return value.isEmpty ? null : value;
  }

  static Future<bool> saveUser(LoggedInUserModel user) async {
    final saved = await SharedPreferencesHelper.saveData(
      key: UserSessionKeys.loggedInUser,
      value: jsonEncode(user.toJson()),
    );

    return saved == true;
  }

  static LoggedInUserModel? getUser() {
    final raw = readString(UserSessionKeys.loggedInUser);
    if (raw == null) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;

      return LoggedInUserModel.fromJson(
        Map<String, dynamic>.from(decoded),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> removeUser() async {
    await SharedPreferencesHelper.removeData(key: UserSessionKeys.loggedInUser);
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
