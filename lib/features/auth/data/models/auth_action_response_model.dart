String? _asString(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is num || value is bool) return value.toString();
  return null;
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

AuthActionResponseModel authActionResponseModelFromJson(dynamic json) => AuthActionResponseModel.fromJson(
      json is Map<String, dynamic> ? json : Map<String, dynamic>.from(json as Map),
    );

class AuthActionResponseModel {
  final bool success;
  final String? code;
  final String? message;
  final Map<String, dynamic>? data;
  final String? expiresAt;

  AuthActionResponseModel({
    required this.success,
    this.code,
    this.message,
    this.data,
    this.expiresAt,
  });

  factory AuthActionResponseModel.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data']);
    return AuthActionResponseModel(
      success: json['success'] == true,
      code: _asString(json['code']),
      message: _asString(json['message']),
      data: data,
      expiresAt: _asString(json['expiresAt']) ?? _asString(data?['expiresAt']),
    );
  }

  String? get phone => _asString(data?['phone']);
  String? get nextAction => _asString(data?['next_action']);
}
