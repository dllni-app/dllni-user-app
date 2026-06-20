import 'dart:convert';

import 'package:common_package/common_package.dart';
import 'package:flutter/foundation.dart';

import '../../features/auth/data/models/login_response_model.dart';
import 'user_session_keys.dart';

abstract final class UserSessionStore {
  static const String defaultDisplayNamePlaceholder = 'اسم المستخدم';

  static final ValueNotifier<LoggedInUserModel?> userNotifier =
      ValueNotifier<LoggedInUserModel?>(null);

  static LoggedInUserModel? get currentUser {
    return userNotifier.value ?? readStoredUser();
  }

  static String displayName([LoggedInUserModel? user]) {
    final value = (user ?? currentUser)?.name?.trim();
    if (value == null || value.isEmpty) return defaultDisplayNamePlaceholder;
    return value;
  }

  static String? phone([LoggedInUserModel? user]) {
    final value = (user ?? currentUser)?.phone?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  static LoggedInUserModel? readStoredUser() {
    final raw = SharedPreferencesHelper.getData(key: UserSessionKeys.loggedInUser);
    if (raw == null) return null;

    try {
      final decoded = jsonDecode('$raw');
      if (decoded is! Map) return null;
      return LoggedInUserModel.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }

  static Future<void> restoreFromDisk() async {
    userNotifier.value = readStoredUser();
  }

  static Future<void> writeAndMirror(LoggedInUserModel user) async {
    userNotifier.value = user;

    await SharedPreferencesHelper.saveData(
      key: UserSessionKeys.loggedInUser,
      value: jsonEncode(user.toJson()),
    );

    await _writeOrRemove(UserSessionKeys.customerName, user.name);
    await _writeOrRemove(UserSessionKeys.customerEmail, user.email);
    await _writeOrRemove(UserSessionKeys.customerPhone, user.phone);
    await _writeOrRemove(
      UserSessionKeys.customerAvatarUrl,
      user.primaryImage?.url,
    );
    await _writeOrRemove(
      UserSessionKeys.customerPhoneVerifiedAt,
      user.phoneVerifiedAt,
    );

    if (user.id != null) {
      await SharedPreferencesHelper.saveData(
        key: UserSessionKeys.customerId,
        value: user.id,
      );
    } else {
      await SharedPreferencesHelper.removeData(key: UserSessionKeys.customerId);
    }
  }

  static Future<void> clear() async {
    userNotifier.value = null;
    await SharedPreferencesHelper.removeData(key: UserSessionKeys.loggedInUser);
    await SharedPreferencesHelper.removeData(key: UserSessionKeys.customerId);
    await SharedPreferencesHelper.removeData(key: UserSessionKeys.customerName);
    await SharedPreferencesHelper.removeData(key: UserSessionKeys.customerEmail);
    await SharedPreferencesHelper.removeData(key: UserSessionKeys.customerPhone);
    await SharedPreferencesHelper.removeData(key: UserSessionKeys.customerAvatarUrl);
    await SharedPreferencesHelper.removeData(
      key: UserSessionKeys.customerPhoneVerifiedAt,
    );
  }

  static Future<void> _writeOrRemove(String key, String? value) async {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      await SharedPreferencesHelper.removeData(key: key);
      return;
    }
    await SharedPreferencesHelper.saveData(key: key, value: trimmed);
  }
}
