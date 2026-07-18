import 'dart:convert';

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

bool? _toBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) {
    if (value == 1) return true;
    if (value == 0) return false;
  }
  final text = value?.toString().trim().toLowerCase();
  if (text == 'true' || text == '1') return true;
  if (text == 'false' || text == '0') return false;
  return null;
}

String? _toString(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is num || value is bool) return value.toString();
  return null;
}

DateTime? _toDateTime(dynamic value) {
  final text = _toString(value);
  if (text == null || text.isEmpty) return null;
  return DateTime.tryParse(text);
}

List<T> _parseList<T>(
  dynamic value,
  T Function(Map<String, dynamic> json) parser,
) {
  if (value is! List) return List<T>.empty(growable: false);

  return value
      .whereType<Map<String, dynamic>>()
      .map(parser)
      .toList(growable: false);
}

CleaningBannersResponseModel cleaningBannersResponseModelFromJson(
  dynamic json,
) {
  if (json is String && json.isNotEmpty) {
    return CleaningBannersResponseModel.fromJson(
      jsonDecode(json) as Map<String, dynamic>,
    );
  }
  if (json is Map<String, dynamic>) {
    return CleaningBannersResponseModel.fromJson(json);
  }
  return const CleaningBannersResponseModel();
}

class CleaningBannersResponseModel {
  final List<CleaningBannerModel> banners;
  final List<CleaningHomeTypeModel> propertyTypes;
  final List<CleaningHomeTypeModel> occasionTypes;

  const CleaningBannersResponseModel({
    this.banners = const <CleaningBannerModel>[],
    this.propertyTypes = const <CleaningHomeTypeModel>[],
    this.occasionTypes = const <CleaningHomeTypeModel>[],
  });

  factory CleaningBannersResponseModel.fromJson(Map<String, dynamic> json) {
    return CleaningBannersResponseModel(
      banners: _parseList(json['banners'], CleaningBannerModel.fromJson),
      propertyTypes: _parseList(
        json['propertyTypes'] ?? json['property_types'],
        CleaningHomeTypeModel.fromJson,
      ),
      occasionTypes: _parseList(
        json['occasionTypes'] ?? json['occasion_types'],
        CleaningHomeTypeModel.fromJson,
      ),
    );
  }
}

class CleaningHomeTypeModel {
  final int? id;
  final String? section;
  final String? code;
  final String? contentCode;
  final String? value;
  final String? title;
  final String? imageUrl;
  final int? sortOrder;

  const CleaningHomeTypeModel({
    this.id,
    this.section,
    this.code,
    this.contentCode,
    this.value,
    this.title,
    this.imageUrl,
    this.sortOrder,
  });

  factory CleaningHomeTypeModel.fromJson(Map<String, dynamic> json) {
    return CleaningHomeTypeModel(
      id: _toInt(json['id']),
      section: _toString(json['section']),
      code: _toString(json['code']),
      contentCode: _toString(json['contentCode'] ?? json['content_code']),
      value: _toString(json['value'] ?? json['booking_value']),
      title: _toString(json['title']),
      imageUrl: _toString(json['imageUrl'] ?? json['image_url']),
      sortOrder: _toInt(json['sortOrder'] ?? json['sort_order']),
    );
  }
}

class CleaningBannerModel {
  final int? id;
  final String? title;
  final String? subtitle;
  final String? imageUrl;
  final String? targetUrl;
  final int? sortOrder;
  final bool? isActive;
  final DateTime? startsAt;
  final DateTime? endsAt;

  const CleaningBannerModel({
    this.id,
    this.title,
    this.subtitle,
    this.imageUrl,
    this.targetUrl,
    this.sortOrder,
    this.isActive,
    this.startsAt,
    this.endsAt,
  });

  factory CleaningBannerModel.fromJson(Map<String, dynamic> json) {
    return CleaningBannerModel(
      id: _toInt(json['id']),
      title: _toString(json['title']),
      subtitle: _toString(json['subtitle']),
      imageUrl: _toString(json['imageUrl'] ?? json['image_url']),
      targetUrl: _toString(json['targetUrl'] ?? json['target_url']),
      sortOrder: _toInt(json['sortOrder'] ?? json['sort_order']),
      isActive: _toBool(json['isActive'] ?? json['is_active']),
      startsAt: _toDateTime(json['startsAt'] ?? json['starts_at']),
      endsAt: _toDateTime(json['endsAt'] ?? json['ends_at']),
    );
  }
}
