String? _asString(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is num || value is bool) return value.toString();
  return null;
}

RegisterResponseModel registerResponseModelFromJson(dynamic json) => RegisterResponseModel.fromJson(
      json is Map<String, dynamic> ? json : Map<String, dynamic>.from(json as Map),
    );

class RegisterResponseModel {
  final String? message;
  final String? expiresAt;

  RegisterResponseModel({this.message, this.expiresAt});

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      message: _asString(json['message']),
      expiresAt: _asString(json['expiresAt']),
    );
  }
}
