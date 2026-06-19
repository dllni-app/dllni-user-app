import 'dart:convert';

import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/features/auth/data/models/login_response_model.dart';

import 'user_session_keys.dart';
import 'user_session_prefs.dart';

class UserSessionStore {
  UserSessionStore._();

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

  static String? get displayName {
    final name = read()?.name?.trim();
    return (name == null || name.isEmpty) ? null : name;
  }

  static String? get phone {
    final value = read()?.phone?.trim();
    return (value == null || value.isEmpty) ? null : value;
  }

  static Future<void> write(LoggedInUserModel user) async {
    await SharedPreferencesHelper.saveData(
      key: UserSessionKeys.loggedInUser,
      value: jsonEncode(user.toJson()),
    );
  }

  static Future<void> clear() async {
    await SharedPreferencesHelper.removeData(key: UserSessionKeys.loggedInUser);
  }

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
