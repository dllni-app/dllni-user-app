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

ChangeStoreFavoriteModel changeStoreFavoriteModelFromJson(str) =>
    ChangeStoreFavoriteModel.fromJson(str);

String changeStoreFavoriteModelToJson(ChangeStoreFavoriteModel data) =>
    json.encode(data.toJson());

ChangeStoreFavoriteModelStore changeStoreFavoriteModelStoreFromJson(str) =>
    ChangeStoreFavoriteModelStore.fromJson(str);

String changeStoreFavoriteModelStoreToJson(
  ChangeStoreFavoriteModelStore data,
) => json.encode(data.toJson());

ChangeStoreFavoriteModelStoreOwner changeStoreFavoriteModelStoreOwnerFromJson(
  str,
) => ChangeStoreFavoriteModelStoreOwner.fromJson(str);

String changeStoreFavoriteModelStoreOwnerToJson(
  ChangeStoreFavoriteModelStoreOwner data,
) => json.encode(data.toJson());

class ChangeStoreFavoriteModel {
  ChangeStoreFavoriteModelStore? store;

  ChangeStoreFavoriteModel({this.store});

  // I comment this for 204 No Content
  factory ChangeStoreFavoriteModel.fromJson(
    dynamic /*Map<String, dynamic>*/ json,
  ) {
    return ChangeStoreFavoriteModel(
      // store: json['store'] is Map ? ChangeStoreFavoriteModelStore.fromJson(Map<String, dynamic>.from(json['store'] as Map)) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'store': store?.toJson()};
  }
}

class ChangeStoreFavoriteModelStore {
  int? id;
  String? name;
  String? slug;
  bool? isActive;
  ChangeStoreFavoriteModelStoreOwner? owner;

  ChangeStoreFavoriteModelStore({
    this.id,
    this.name,
    this.slug,
    this.isActive,
    this.owner,
  });

  factory ChangeStoreFavoriteModelStore.fromJson(Map<String, dynamic> json) {
    return ChangeStoreFavoriteModelStore(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      slug: _asString(json['slug']),
      isActive: _asBool(json['isActive']),
      owner: json['owner'] is Map
          ? ChangeStoreFavoriteModelStoreOwner.fromJson(
              Map<String, dynamic>.from(json['owner'] as Map),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'isActive': isActive,
      'owner': owner?.toJson(),
    };
  }
}

class ChangeStoreFavoriteModelStoreOwner {
  int? id;
  String? name;
  String? email;

  ChangeStoreFavoriteModelStoreOwner({this.id, this.name, this.email});

  factory ChangeStoreFavoriteModelStoreOwner.fromJson(
    Map<String, dynamic> json,
  ) {
    return ChangeStoreFavoriteModelStoreOwner(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      email: _asString(json['email']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email};
  }
}
