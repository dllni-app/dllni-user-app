import 'dart:convert';

String? _asString(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is num || value is bool) return value.toString();
  return null;
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? double.tryParse(value)?.toInt();
  }
  return null;
}

double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

num? _asNum(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}

bool? _asBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) {
    if (value == 1) return true;
    if (value == 0) return false;
  }
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }
  return null;
}

List<dynamic>? _asDynamicList(dynamic value) {
  if (value is! List) return null;
  return value.map(_asDynamic).toList();
}

dynamic _asDynamic(dynamic value) {
  if (value == null) return null;
  if (value is List) {
    return value.map(_asDynamic).toList();
  }
  if (value is Map) {
    final map = <String, dynamic>{};
    value.forEach((key, nestedValue) {
      map['$key'] = _asDynamic(nestedValue);
    });
    return map;
  }
  if (value is String || value is num || value is bool) {
    return value;
  }
  return value.toString();
}

LoginModel loginModelFromJson(str) => LoginModel.fromJson(str);

String loginModelToJson(LoginModel data) => json.encode(data.toJson());


LoginModelUser loginModelUserFromJson(str) => LoginModelUser.fromJson(str);

String loginModelUserToJson(LoginModelUser data) => json.encode(data.toJson());


class LoginModel {
  LoginModelUser? user;
  String? token;

  LoginModel({
    this.user,
    this.token,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      user: json['user'] is Map ? LoginModelUser.fromJson(Map<String, dynamic>.from(json['user'] as Map)) : null,
      token: _asString(json['token']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user?.toJson(),
      'token': token,
    };
  }
}

class LoginModelUser {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? moduleType;
  String? emailVerifiedAt;
  String? createdAt;
  String? updatedAt;

  LoginModelUser({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.moduleType,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory LoginModelUser.fromJson(Map<String, dynamic> json) {
    return LoginModelUser(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      email: _asString(json['email']),
      phone: _asString(json['phone']),
      moduleType: _asString(json['moduleType']),
      emailVerifiedAt: _asString(json['emailVerifiedAt']),
      createdAt: _asString(json['createdAt']),
      updatedAt: _asString(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'moduleType': moduleType,
      'emailVerifiedAt': emailVerifiedAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}