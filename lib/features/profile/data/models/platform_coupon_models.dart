import 'profile_api_models.dart';

double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse('$value');
}

int? _asInt(dynamic value) {
  final number = _asDouble(value);
  return number?.round();
}

String? _asString(dynamic value) {
  if (value == null) return null;
  final text = '$value'.trim();
  return text.isEmpty ? null : text;
}

DateTime? _asDateTime(dynamic value) {
  final text = _asString(value);
  return text == null ? null : DateTime.tryParse(text.replaceFirst(' ', 'T'));
}

Map<String, dynamic> _asMap(dynamic value) {
  return value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
}

List<String> _asStringList(dynamic value) {
  if (value is! List) return const <String>[];
  return value.map(_asString).whereType<String>().toList(growable: false);
}

FetchCouponsModel fetchPlatformCouponsModelFromJson(dynamic json) {
  final payload = json is Map
      ? Map<String, dynamic>.from(json)
      : <String, dynamic>{};
  final coupons = payload['coupons'] is List
      ? (payload['coupons'] as List)
          .whereType<Map>()
          .map(
            (item) => PlatformCouponModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(growable: false)
      : const <PlatformCouponModel>[];

  return FetchCouponsModel(coupons: coupons);
}

class PlatformCouponAppliesToModel {
  final List<String> propertyTypes;
  final List<String> cleaningModes;
  final List<String> eventTypes;

  const PlatformCouponAppliesToModel({
    this.propertyTypes = const <String>[],
    this.cleaningModes = const <String>[],
    this.eventTypes = const <String>[],
  });

  factory PlatformCouponAppliesToModel.fromJson(Map<String, dynamic> json) {
    return PlatformCouponAppliesToModel(
      propertyTypes: _asStringList(json['propertyTypes']),
      cleaningModes: _asStringList(json['cleaningModes']),
      eventTypes: _asStringList(json['eventTypes']),
    );
  }

  bool get isEmpty =>
      propertyTypes.isEmpty && cleaningModes.isEmpty && eventTypes.isEmpty;
}

class PlatformCouponModel extends RestaurantCouponModel {
  final String title;
  final String description;
  final String section;
  final double? maximumDiscountAmount;
  final double? minimumOrderAmount;
  final PlatformCouponAppliesToModel appliesTo;

  const PlatformCouponModel({
    required int? id,
    required String? code,
    required String? discountType,
    required double? discountValue,
    required int? minOrderAmount,
    required DateTime? startsAt,
    required DateTime? endsAt,
    required this.title,
    required this.description,
    required this.section,
    required this.maximumDiscountAmount,
    required this.minimumOrderAmount,
    required this.appliesTo,
  }) : super(
          id: id,
          code: code,
          discountType: discountType,
          discountValue: discountValue,
          minOrderAmount: minOrderAmount,
          startsAt: startsAt,
          endsAt: endsAt,
          isActive: true,
        );

  factory PlatformCouponModel.fromJson(Map<String, dynamic> json) {
    final discount = _asMap(json['discount']);
    final minOrder = _asDouble(json['minOrderAmount']);

    return PlatformCouponModel(
      id: _asInt(json['id']),
      code: _asString(json['code']),
      title: _asString(json['title']) ?? '',
      description: _asString(json['description']) ?? '',
      section: _asString(json['section']) ?? 'all',
      discountType: _asString(discount['type']),
      discountValue: _asDouble(discount['value']),
      maximumDiscountAmount: _asDouble(discount['maxAmount']),
      minimumOrderAmount: minOrder,
      minOrderAmount: minOrder?.round(),
      startsAt: _asDateTime(json['startsAt']),
      endsAt: _asDateTime(json['expiresAt']),
      appliesTo: PlatformCouponAppliesToModel.fromJson(
        _asMap(json['appliesTo']),
      ),
    );
  }

  bool appliesToSection(String selectedSection) {
    return selectedSection == 'all' ||
        section == 'all' ||
        section == selectedSection;
  }
}
