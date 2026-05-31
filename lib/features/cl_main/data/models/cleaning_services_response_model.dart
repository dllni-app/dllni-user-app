import 'dart:convert';

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
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

CleaningServicesResponseModel cleaningServicesResponseModelFromJson(
  dynamic json,
) {
  if (json is String && json.isNotEmpty) {
    return CleaningServicesResponseModel.fromJson(
      jsonDecode(json) as Map<String, dynamic>,
    );
  }
  if (json is Map<String, dynamic>) {
    return CleaningServicesResponseModel.fromJson(json);
  }
  return const CleaningServicesResponseModel();
}

class CleaningServicesResponseModel {
  final List<CleaningServiceModel> data;

  const CleaningServicesResponseModel({
    this.data = const <CleaningServiceModel>[],
  });

  factory CleaningServicesResponseModel.fromJson(Map<String, dynamic> json) {
    final dataRaw = json['data'];
    final data = dataRaw is List
        ? dataRaw
              .whereType<Map<String, dynamic>>()
              .map(CleaningServiceModel.fromJson)
              .toList(growable: false)
        : const <CleaningServiceModel>[];

    return CleaningServicesResponseModel(data: data);
  }
}

class CleaningServiceModel {
  final int? id;
  final String? name;
  final String? category;
  final bool? isActive;
  final List<CleaningServicePricingModel> pricing;

  const CleaningServiceModel({
    this.id,
    this.name,
    this.category,
    this.isActive,
    this.pricing = const <CleaningServicePricingModel>[],
  });

  factory CleaningServiceModel.fromJson(Map<String, dynamic> json) {
    final pricingRaw = json['pricing'];
    final pricing = pricingRaw is List
        ? pricingRaw
              .whereType<Map<String, dynamic>>()
              .map(CleaningServicePricingModel.fromJson)
              .toList(growable: false)
        : const <CleaningServicePricingModel>[];

    return CleaningServiceModel(
      id: _toInt(json['id']),
      name: (json['name'] ?? json['nameAr']) as String?,
      category: (json['category']) as String?,
      isActive: _toBool(json['isActive'] ?? json['is_active']),
      pricing: pricing,
    );
  }
}

class CleaningServicePricingModel {
  final String? propertyType;
  final String? livingRoomSize;
  final double? basePrice;
  final double? pricePerSqm;
  final double? minHours;

  const CleaningServicePricingModel({
    this.propertyType,
    this.livingRoomSize,
    this.basePrice,
    this.pricePerSqm,
    this.minHours,
  });

  factory CleaningServicePricingModel.fromJson(Map<String, dynamic> json) {
    return CleaningServicePricingModel(
      propertyType: (json['propertyType'] ?? json['property_type']) as String?,
      livingRoomSize:
          (json['livingRoomSize'] ?? json['living_room_size']) as String?,
      basePrice: _toDouble(json['basePrice'] ?? json['base_price']),
      pricePerSqm: _toDouble(json['pricePerSqm'] ?? json['price_per_sqm']),
      minHours: _toDouble(json['minHours'] ?? json['min_hours']),
    );
  }
}
