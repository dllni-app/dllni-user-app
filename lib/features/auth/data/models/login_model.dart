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

LoginModel loginModelFromJson(str) => LoginModel.fromJson(str);

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

LoginModelUser loginModelUserFromJson(str) => LoginModelUser.fromJson(str);

String loginModelUserToJson(LoginModelUser data) => json.encode(data.toJson());

class LoginModel {
  LoginModelUser? user;
  String? token;
  LoginModelRole? role;
  List<LoginModelPermission>? permissions;

  LoginModel({this.user, this.token, this.role, this.permissions});

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      user: json['user'] is Map ? LoginModelUser.fromJson(Map<String, dynamic>.from(json['user'] as Map)) : null,
      token: _asString(json['token']),
      role: json['role'] is Map ? LoginModelRole.fromJson(Map<String, dynamic>.from(json['role'])) : null,
      permissions: json['permissions'] is List
          ? (json['permissions'] as List).whereType<Map>().map((e) => LoginModelPermission.fromJson(Map<String, dynamic>.from(e))).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user?.toJson(),
      'token': token,
      'role': role?.toJson(),
      'permissions': permissions?.map((e) => e.toJson()).toList(),
    };
  }
}

class LoginModelRole {
  int? id;
  String? name;
  String? slug;

  LoginModelRole({this.id, this.name, this.slug});

  factory LoginModelRole.fromJson(Map<String, dynamic> json) {
    return LoginModelRole(id: _asInt(json['id']), name: _asString(json['name']), slug: _asString(json['slug']));
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'slug': slug};
  }
}

class LoginModelPermission {
  int? id;
  String? name;
  String? slug;
  String? group;

  LoginModelPermission({this.id, this.name, this.slug, this.group});

  factory LoginModelPermission.fromJson(Map<String, dynamic> json) {
    return LoginModelPermission(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      slug: _asString(json['slug']),
      group: _asString(json['group']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'slug': slug, 'group': group};
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

  LoginModelUser({this.id, this.name, this.email, this.phone, this.moduleType, this.emailVerifiedAt, this.createdAt, this.updatedAt});

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
