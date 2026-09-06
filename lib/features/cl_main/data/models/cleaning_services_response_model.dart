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

String? _toString(dynamic value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
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
  final String? imageUrl;
  final String? pricingUnit;
  final double? baseUnitPrice;
  final List<CleaningServiceDirtinessRuleModel> dirtinessRules;
  final List<CleaningServiceEquipmentModel> equipment;
  final List<CleaningServicePricingModel> pricing;

  const CleaningServiceModel({
    this.id,
    this.name,
    this.category,
    this.isActive,
    this.imageUrl,
    this.pricingUnit,
    this.baseUnitPrice,
    this.dirtinessRules = const <CleaningServiceDirtinessRuleModel>[],
    this.equipment = const <CleaningServiceEquipmentModel>[],
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

    final dirtinessRaw = json['dirtinessRules'] ?? json['dirtiness_rules'];
    final dirtinessRules = dirtinessRaw is List
        ? dirtinessRaw
              .whereType<Map<String, dynamic>>()
              .map(CleaningServiceDirtinessRuleModel.fromJson)
              .where((rule) => rule.level != null && rule.isActive != false)
              .toList(growable: false)
        : const <CleaningServiceDirtinessRuleModel>[];

    final equipmentRaw = json['equipment'];
    final equipment = equipmentRaw is List
        ? equipmentRaw
              .whereType<Map<String, dynamic>>()
              .map(CleaningServiceEquipmentModel.fromJson)
              .where((item) => item.name != null)
              .toList(growable: false)
        : const <CleaningServiceEquipmentModel>[];

    return CleaningServiceModel(
      id: _toInt(json['id']),
      name: _toString(json['name'] ?? json['nameAr']),
      category: _toString(json['category']),
      isActive: _toBool(json['isActive'] ?? json['is_active']),
      imageUrl: _toString(json['image'] ?? json['imageUrl'] ?? json['image_url']),
      pricingUnit: _toString(json['pricingUnit'] ?? json['pricing_unit']),
      baseUnitPrice: _toDouble(json['baseUnitPrice'] ?? json['base_unit_price']),
      dirtinessRules: dirtinessRules,
      equipment: equipment,
      pricing: pricing,
    );
  }
}

class CleaningServiceDirtinessRuleModel {
  final String? level;
  final double? priceMultiplier;
  final bool? isActive;

  const CleaningServiceDirtinessRuleModel({
    this.level,
    this.priceMultiplier,
    this.isActive,
  });

  factory CleaningServiceDirtinessRuleModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CleaningServiceDirtinessRuleModel(
      level: _toString(json['level'] ?? json['dirtinessLevel'] ?? json['dirtiness_level']),
      priceMultiplier: _toDouble(
        json['priceMultiplier'] ?? json['price_multiplier'],
      ),
      isActive: _toBool(json['isActive'] ?? json['is_active']),
    );
  }
}

class CleaningServiceEquipmentModel {
  final int? id;
  final String? name;

  const CleaningServiceEquipmentModel({this.id, this.name});

  factory CleaningServiceEquipmentModel.fromJson(Map<String, dynamic> json) {
    return CleaningServiceEquipmentModel(
      id: _toInt(json['id']),
      name: _toString(json['name']),
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
      propertyType: _toString(json['propertyType'] ?? json['property_type']),
      livingRoomSize: _toString(
        json['livingRoomSize'] ?? json['living_room_size'],
      ),
      basePrice: _toDouble(json['basePrice'] ?? json['base_price']),
      pricePerSqm: _toDouble(json['pricePerSqm'] ?? json['price_per_sqm']),
      minHours: _toDouble(json['minHours'] ?? json['min_hours']),
    );
  }
}
