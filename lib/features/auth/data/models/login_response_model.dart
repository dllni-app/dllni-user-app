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

LoginResponseModel loginResponseModelFromJson(dynamic json) => LoginResponseModel.fromJson(
      json is Map<String, dynamic> ? json : Map<String, dynamic>.from(json as Map),
    );

class LoginResponseModel {
  final LoggedInUserModel? data;
  final String? token;

  LoginResponseModel({this.data, this.token});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      data: json['data'] != null
          ? LoggedInUserModel.fromJson(Map<String, dynamic>.from(json['data'] as Map))
          : null,
      token: _asString(json['token']),
    );
  }
}

class LoggedInUserModel {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? phoneVerifiedAt;
  final String? moduleType;
  final String? emailVerifiedAt;
  final UserPrimaryImageModel? primaryImage;
  final List<UserPrimaryImageModel> images;
  final String? createdAt;
  final String? updatedAt;

  LoggedInUserModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.phoneVerifiedAt,
    this.moduleType,
    this.emailVerifiedAt,
    this.primaryImage,
    this.images = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory LoggedInUserModel.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];
    final images = <UserPrimaryImageModel>[];
    if (rawImages is List) {
      for (final item in rawImages) {
        if (item is Map) {
          images.add(UserPrimaryImageModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return LoggedInUserModel(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      email: _asString(json['email']),
      phone: _asString(json['phone']),
      phoneVerifiedAt: _asString(json['phoneVerifiedAt']),
      moduleType: _asString(json['moduleType']),
      emailVerifiedAt: _asString(json['emailVerifiedAt']),
      primaryImage: json['primaryImage'] != null
          ? UserPrimaryImageModel.fromJson(Map<String, dynamic>.from(json['primaryImage'] as Map))
          : null,
      images: images,
      createdAt: _asString(json['createdAt']),
      updatedAt: _asString(json['updatedAt']),
    );
  }
}

class UserPrimaryImageModel {
  final int? id;
  final String? name;
  final String? fileName;
  final String? collection;
  final String? url;
  final String? thumbnailUrl;
  final String? size;
  final String? extension;
  final String? type;
  final String? caption;
  final String? createdAt;

  UserPrimaryImageModel({
    this.id,
    this.name,
    this.fileName,
    this.collection,
    this.url,
    this.thumbnailUrl,
    this.size,
    this.extension,
    this.type,
    this.caption,
    this.createdAt,
  });

  factory UserPrimaryImageModel.fromJson(Map<String, dynamic> json) {
    return UserPrimaryImageModel(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      fileName: _asString(json['fileName']),
      collection: _asString(json['collection']),
      url: _asString(json['url']),
      thumbnailUrl: _asString(json['thumbnailUrl']),
      size: _asString(json['size']),
      extension: _asString(json['extension']),
      type: _asString(json['type']),
      caption: _asString(json['caption']),
      createdAt: _asString(json['createdAt']),
    );
  }
}
