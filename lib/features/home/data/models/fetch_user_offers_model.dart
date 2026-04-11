import 'dart:convert';

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? double.tryParse(value)?.toInt();
  }
  return null;
}

String? _asString(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is num || value is bool) return value.toString();
  return null;
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

List<Map<String, dynamic>> _asMapList(dynamic value) {
  if (value is List) {
    return value.map((item) => _asMap(item)).toList();
  }
  return <Map<String, dynamic>>[];
}

FetchUserOffersModel fetchUserOffersModelFromJson(dynamic json) =>
    FetchUserOffersModel.fromJson(_asMap(json));

String fetchUserOffersModelToJson(FetchUserOffersModel data) =>
    json.encode(data.toJson());

class FetchUserOffersModel {
  List<UserOfferItem> data;
  UserOffersLinksModel? links;
  UserOffersMetaModel? meta;

  FetchUserOffersModel({
    required this.data,
    this.links,
    this.meta,
  });

  factory FetchUserOffersModel.fromJson(Map<String, dynamic> json) {
    return FetchUserOffersModel(
      data: _asMapList(json['data'])
          .map(UserOfferItem.fromJson)
          .toList(),
      links: json['links'] == null
          ? null
          : UserOffersLinksModel.fromJson(_asMap(json['links'])),
      meta: json['meta'] == null
          ? null
          : UserOffersMetaModel.fromJson(_asMap(json['meta'])),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((e) => e.toJson()).toList(),
      'links': links?.toJson(),
      'meta': meta?.toJson(),
    };
  }
}

class UserOffersLinksModel {
  String? first;
  String? last;
  String? prev;
  String? next;

  UserOffersLinksModel({this.first, this.last, this.prev, this.next});

  factory UserOffersLinksModel.fromJson(Map<String, dynamic> json) {
    return UserOffersLinksModel(
      first: _asString(json['first']),
      last: _asString(json['last']),
      prev: _asString(json['prev']),
      next: _asString(json['next']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first': first,
      'last': last,
      'prev': prev,
      'next': next,
    };
  }
}

class UserOffersMetaModel {
  int? currentPage;
  int? from;
  int? lastPage;
  int? perPage;
  int? to;
  int? total;

  UserOffersMetaModel({
    this.currentPage,
    this.from,
    this.lastPage,
    this.perPage,
    this.to,
    this.total,
  });

  factory UserOffersMetaModel.fromJson(Map<String, dynamic> json) {
    return UserOffersMetaModel(
      currentPage: _asInt(json['current_page']),
      from: _asInt(json['from']),
      lastPage: _asInt(json['last_page']),
      perPage: _asInt(json['per_page']),
      to: _asInt(json['to']),
      total: _asInt(json['total']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'from': from,
      'last_page': lastPage,
      'per_page': perPage,
      'to': to,
      'total': total,
    };
  }
}

class UserOfferItem {
  int? id;
  String? title;
  String? description;
  String? discountLabel;
  String? promoCode;
  String? startsAt;
  String? endsAt;
  String? theme;
  int? sortOrder;
  String? imageUrl;
  String? createdAt;
  String? updatedAt;

  UserOfferItem({
    this.id,
    this.title,
    this.description,
    this.discountLabel,
    this.promoCode,
    this.startsAt,
    this.endsAt,
    this.theme,
    this.sortOrder,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory UserOfferItem.fromJson(Map<String, dynamic> json) {
    return UserOfferItem(
      id: _asInt(json['id']),
      title: _asString(json['title']),
      description: _asString(json['description']),
      discountLabel: _asString(json['discountLabel']),
      promoCode: _asString(json['promoCode']),
      startsAt: _asString(json['startsAt']),
      endsAt: _asString(json['endsAt']),
      theme: _asString(json['theme']),
      sortOrder: _asInt(json['sortOrder']),
      imageUrl: _asString(json['imageUrl']),
      createdAt: _asString(json['createdAt']),
      updatedAt: _asString(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'discountLabel': discountLabel,
      'promoCode': promoCode,
      'startsAt': startsAt,
      'endsAt': endsAt,
      'theme': theme,
      'sortOrder': sortOrder,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
