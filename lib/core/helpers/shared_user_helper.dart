
import 'dart:convert';

import '../../features/auth/data/models/login_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SharedUserHelper {
  static SharedPreferences? sharedPreferences;

  static Future<void> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  // =========================
  // 🔥 USER MODEL CACHE
  // =========================

  static const String _userKey = 'user';

  static Future<bool?> saveUser(LoggedInUserModel user) async {
    if (sharedPreferences == null) return false;

    return await sharedPreferences!.setString(
      _userKey,
      jsonEncode(user.toJson()),
    );
  }

  static LoggedInUserModel? getUser() {
    final raw = sharedPreferences?.getString(_userKey);

    if (raw == null) return null;

    try {
      final json = jsonDecode(raw);
      return LoggedInUserModel.fromJson(Map<String, dynamic>.from(json));
    } catch (e) {
      return null;
    }
  }

  // =========================
  // 🔥 GENERIC METHODS
  // =========================

  static Future<dynamic> saveData({
    required String key,
    required dynamic value,
  }) async {
    if (value is String) {
      return await sharedPreferences?.setString(key, value);
    }
    if (value is int) {
      return await sharedPreferences?.setInt(key, value);
    }
    if (value is bool) {
      return await sharedPreferences?.setBool(key, value);
    }
    if (value is double) {
      return await sharedPreferences?.setDouble(key, value);
    }

    return await sharedPreferences?.setString(key, jsonEncode(value));
  }

  static dynamic getData({required String key}) {
    return sharedPreferences?.get(key);
  }

  static Future<bool?> removeData({required String key}) async {
    return await sharedPreferences?.remove(key);
  }

  static Future<bool?> clearData() async {
    return await sharedPreferences?.clear();
  }
}
