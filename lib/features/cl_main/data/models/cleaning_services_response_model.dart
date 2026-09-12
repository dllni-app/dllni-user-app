import 'dart:convert';

const List<String> cleaningServiceFallbackDirtinessLevels = <String>[
  'light',
  'medium',
  'heavy',
];

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
  final int? categoryId;
  final String? categoryName;
  final String? description;
  final bool? isActive;
  final String? imageUrl;
  final String? pricingUnit;
  final String? inputType;
  final String? unitCode;
  final double? baseUnitPrice;
  final bool supportsDirtiness;
  final String? genderConstraint;
  final int? estimatedDurationMinutes;
  final bool requiresBeforeImage;
  final bool requiresAfterImage;
  final List<CleaningServiceDirtinessRuleModel> dirtinessRules;
  final List<CleaningServiceEquipmentModel> equipment;
  final List<CleaningServicePricingModel> pricing;

  const CleaningServiceModel({
    this.id,
    this.name,
    this.category,
    this.categoryId,
    this.categoryName,
    this.description,
    this.isActive,
    this.imageUrl,
    this.pricingUnit,
    this.inputType,
    this.unitCode,
    this.baseUnitPrice,
    this.supportsDirtiness = true,
    this.genderConstraint,
    this.estimatedDurationMinutes,
    this.requiresBeforeImage = false,
    this.requiresAfterImage = false,
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

    final dirtinessRaw =
        json['dirtinessLevels'] ??
        json['dirtiness_levels'] ??
        json['dirtinessRules'] ??
        json['dirtiness_rules'];
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
      categoryId: _toInt(json['categoryId'] ?? json['category_id']),
      categoryName: _toString(json['categoryName'] ?? json['category_name']),
      description: _toString(json['description']),
      isActive: _toBool(json['isActive'] ?? json['is_active']),
      imageUrl: _toString(
        json['image'] ?? json['imageUrl'] ?? json['image_url'],
      ),
      pricingUnit: _toString(json['pricingUnit'] ?? json['pricing_unit']),
      inputType: _toString(json['inputType'] ?? json['input_type']),
      unitCode: _toString(json['unitCode'] ?? json['unit_code']),
      baseUnitPrice: _toDouble(
        json['baseUnitPrice'] ?? json['base_unit_price'],
      ),
      supportsDirtiness:
          _toBool(json['supportsDirtiness'] ?? json['supports_dirtiness']) ??
          true,
      genderConstraint: _toString(
        json['genderConstraint'] ?? json['gender_constraint'],
      ),
      estimatedDurationMinutes: _toInt(
        json['estimatedDurationMinutes'] ?? json['estimated_duration_minutes'],
      ),
      requiresBeforeImage:
          _toBool(
            json['requiresBeforeImage'] ?? json['requires_before_image'],
          ) ??
          false,
      requiresAfterImage:
          _toBool(json['requiresAfterImage'] ?? json['requires_after_image']) ??
          false,
      dirtinessRules: dirtinessRules,
      equipment: equipment,
      pricing: pricing,
    );
  }

  List<String> get selectableDirtinessLevels {
    final levels = <String>[];
    for (final rule in dirtinessRules) {
      final level = rule.level?.trim();
      if (level == null || level.isEmpty || levels.contains(level)) continue;
      levels.add(level);
    }
    return levels.isEmpty
        ? cleaningServiceFallbackDirtinessLevels
        : List<String>.unmodifiable(levels);
  }

  String normalizeDirtinessLevel(
    String? value, {
    String preferredFallback = 'medium',
  }) {
    final levels = selectableDirtinessLevels;
    final normalized = value?.trim();
    if (normalized != null && levels.contains(normalized)) return normalized;
    if (levels.contains(preferredFallback)) return preferredFallback;
    return levels.first;
  }
}

class CleaningServiceDirtinessRuleModel {
  final int? id;
  final String? name;
  final String? slug;
  final String? level;
  final double? priceMultiplier;
  final bool? isActive;

  const CleaningServiceDirtinessRuleModel({
    this.id,
    this.name,
    this.slug,
    this.level,
    this.priceMultiplier,
    this.isActive,
  });

  factory CleaningServiceDirtinessRuleModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CleaningServiceDirtinessRuleModel(
      id: _toInt(json['id']),
      name: _toString(json['name']),
      slug: _toString(json['slug']),
      level: _toString(
        json['level'] ??
            json['slug'] ??
            json['dirtinessLevel'] ??
            json['dirtiness_level'],
      ),
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
