import 'dart:convert';

import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/features/auth/data/models/login_response_model.dart';
import 'package:flutter/foundation.dart';

import 'user_session_keys.dart';
import 'user_session_prefs.dart';

class UserSessionStore {
  UserSessionStore._();

  static const String defaultDisplayNamePlaceholder = 'اسم المستخدم';

  static final ValueNotifier<LoggedInUserModel?> userNotifier =
      ValueNotifier<LoggedInUserModel?>(null);

  static LoggedInUserModel? get currentUser => userNotifier.value ?? read();

  static LoggedInUserModel? read() {
    final raw = SharedPreferencesHelper.getData(key: UserSessionKeys.loggedInUser);
    if (raw == null) return null;

    try {
      final decoded = jsonDecode('$raw');
      if (decoded is! Map) return null;

      return LoggedInUserModel.fromJson(
        Map<String, dynamic>.from(decoded),
      );
    } catch (_) {
      return null;
    }
  }

  static void reload() {
    userNotifier.value = read();
  }

  static String? displayName({String? fallback}) {
    final name = currentUser?.name?.trim();
    if (name == null || name.isEmpty) return fallback;
    return name;
  }

  static String displayNameOrPlaceholder() {
    return displayName(fallback: defaultDisplayNamePlaceholder) ??
        defaultDisplayNamePlaceholder;
  }

  static String? get phone {
    final value = currentUser?.phone?.trim();
    return (value == null || value.isEmpty) ? null : value;
  }

  static Future<void> saveLoginResponse(LoginResponseModel result) async {
    final token = result.token?.trim() ?? '';
    if (token.isNotEmpty) {
      await SharedPreferencesHelper.saveData(
        key: UserSessionKeys.token,
        value: token,
      );
    } else {
      await SharedPreferencesHelper.removeData(key: UserSessionKeys.token);
    }

    final customerId = result.data?.id;
    if (customerId != null) {
      await SharedPreferencesHelper.saveData(
        key: UserSessionKeys.customerId,
        value: customerId,
      );
    } else {
      await SharedPreferencesHelper.removeData(key: UserSessionKeys.customerId);
    }

    final user = result.data;
    if (user != null) {
      await writeAndMirror(user);
    } else {
      await clearUserProfile();
    }
  }

  static Future<void> write(LoggedInUserModel user) async {
    await SharedPreferencesHelper.saveData(
      key: UserSessionKeys.loggedInUser,
      value: jsonEncode(user.toJson()),
    );
    userNotifier.value = user;
  }

  static Future<void> clearUserProfile() async {
    await SharedPreferencesHelper.removeData(key: UserSessionKeys.loggedInUser);
    await UserSessionPrefs.saveUserProfile(
      name: null,
      email: null,
      phone: null,
      avatarUrl: null,
      phoneVerifiedAt: null,
    );
    userNotifier.value = null;
  }

  static Future<void> clear() => clearUserProfile();

  static Future<void> writeAndMirror(LoggedInUserModel user) async {
    await write(user);
    await UserSessionPrefs.saveUserProfile(
      name: user.name,
      email: user.email,
      phone: user.phone,
      avatarUrl: _resolveAvatarUrl(user),
      phoneVerifiedAt: user.phoneVerifiedAt,
    );
  }

  static String? _resolveAvatarUrl(LoggedInUserModel user) {
    final primary = user.primaryImage;
    final primaryUrl = (primary?.url ?? primary?.thumbnailUrl)?.trim();
    if (primaryUrl != null && primaryUrl.isNotEmpty) {
      return primaryUrl;
    }
    for (final image in user.images) {
      final imageUrl = (image.url ?? image.thumbnailUrl)?.trim();
      if (imageUrl != null && imageUrl.isNotEmpty) {
        return imageUrl;
      }
    }
    return null;
  }
}
