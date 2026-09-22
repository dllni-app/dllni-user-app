import 'dart:convert';

CleaningSuiteConfigModel cleaningSuiteConfigModelFromJson(dynamic value) {
  final decoded = value is String ? jsonDecode(value) : value;
  final root = _map(decoded);
  return CleaningSuiteConfigModel.fromJson(_map(root['data'] ?? root));
}

class CleaningSuiteConfigModel {
  const CleaningSuiteConfigModel({
    this.schemaVersion = 1,
    this.serverNow,
    this.capabilities = const <String, bool>{},
    this.openTime = const CleaningOpenTimePolicyModel(),
    this.dirtinessLevels = const <CleaningDirtinessLevelConfigModel>[],
    this.specialServiceCategories =
        const <CleaningSpecialServiceCategoryConfigModel>[],
    this.uncategorizedSpecialServices =
        const <CleaningSpecialServiceConfigModel>[],
    this.eventTypes = const <CleaningEventTypeConfigModel>[],
  });

  final int schemaVersion;
  final String? serverNow;
  final Map<String, bool> capabilities;
  final CleaningOpenTimePolicyModel openTime;
  final List<CleaningDirtinessLevelConfigModel> dirtinessLevels;
  final List<CleaningSpecialServiceCategoryConfigModel>
  specialServiceCategories;
  final List<CleaningSpecialServiceConfigModel> uncategorizedSpecialServices;
  final List<CleaningEventTypeConfigModel> eventTypes;

  factory CleaningSuiteConfigModel.fromJson(Map<String, dynamic> json) {
    return CleaningSuiteConfigModel(
      schemaVersion:
          _integer(json['schemaVersion'] ?? json['schema_version']) ?? 1,
      serverNow: _text(json['serverNow'] ?? json['server_now']),
      capabilities: _map(
        json['capabilities'],
      ).map((key, value) => MapEntry(key, _boolean(value) ?? false)),
      openTime: CleaningOpenTimePolicyModel.fromJson(_map(json['openTime'])),
      dirtinessLevels: _list(json['dirtinessLevels'])
          .map((item) => CleaningDirtinessLevelConfigModel.fromJson(_map(item)))
          .toList(growable: false),
      specialServiceCategories: _list(json['specialServiceCategories'])
          .map(
            (item) =>
                CleaningSpecialServiceCategoryConfigModel.fromJson(_map(item)),
          )
          .toList(growable: false),
      uncategorizedSpecialServices: _list(json['uncategorizedSpecialServices'])
          .map((item) => CleaningSpecialServiceConfigModel.fromJson(_map(item)))
          .toList(growable: false),
      eventTypes: _list(json['eventTypes'])
          .map((item) => CleaningEventTypeConfigModel.fromJson(_map(item)))
          .toList(growable: false),
    );
  }

  List<CleaningSpecialServiceConfigModel> get specialServices =>
      <CleaningSpecialServiceConfigModel>[
        for (final category in specialServiceCategories) ...category.services,
        ...uncategorizedSpecialServices,
      ];
}

class CleaningOpenTimePolicyModel {
  const CleaningOpenTimePolicyModel({
    this.durationOptions = const <int>[60, 120, 180, 240, 480],
    this.extensionOptions = const <int>[15, 30, 60],
    this.legacyDefaultMinutes = 480,
    this.hardMaxMinutes = 480,
    this.warningMinutes = 30,
    this.minimumBillableMinutes = 60,
    this.roundingMinutes = 15,
  });

  final List<int> durationOptions;
  final List<int> extensionOptions;
  final int legacyDefaultMinutes;
  final int hardMaxMinutes;
  final int warningMinutes;
  final int minimumBillableMinutes;
  final int roundingMinutes;

  factory CleaningOpenTimePolicyModel.fromJson(Map<String, dynamic> json) {
    List<int> values(dynamic source, List<int> fallback) {
      final result =
          _list(source)
              .map(_integer)
              .whereType<int>()
              .where((value) => value > 0)
              .toSet()
              .toList()
            ..sort();
      return result.isEmpty ? fallback : List<int>.unmodifiable(result);
    }

    return CleaningOpenTimePolicyModel(
      durationOptions: values(json['durationOptions'], const <int>[
        60,
        120,
        180,
        240,
        480,
      ]),
      extensionOptions: values(json['extensionOptions'], const <int>[
        15,
        30,
        60,
      ]),
      legacyDefaultMinutes: _integer(json['legacyDefaultMinutes']) ?? 480,
      hardMaxMinutes: _integer(json['hardMaxMinutes']) ?? 480,
      warningMinutes: _integer(json['warningMinutes']) ?? 30,
      minimumBillableMinutes: _integer(json['minimumBillableMinutes']) ?? 60,
      roundingMinutes: _integer(json['roundingMinutes']) ?? 15,
    );
  }
}

class CleaningDirtinessLevelConfigModel {
  const CleaningDirtinessLevelConfigModel({
    required this.id,
    required this.name,
    required this.slug,
    this.priceMultiplier = 1,
  });

  final int id;
  final String name;
  final String slug;
  final double priceMultiplier;

  factory CleaningDirtinessLevelConfigModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CleaningDirtinessLevelConfigModel(
      id: _integer(json['id']) ?? 0,
      name: _text(json['name']) ?? '',
      slug: _text(json['slug']) ?? '',
      priceMultiplier: _decimal(json['priceMultiplier']) ?? 1,
    );
  }
}

class CleaningSpecialServiceCategoryConfigModel {
  const CleaningSpecialServiceCategoryConfigModel({
    required this.id,
    required this.name,
    required this.slug,
    this.services = const <CleaningSpecialServiceConfigModel>[],
  });

  final int id;
  final String name;
  final String slug;
  final List<CleaningSpecialServiceConfigModel> services;

  factory CleaningSpecialServiceCategoryConfigModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CleaningSpecialServiceCategoryConfigModel(
      id: _integer(json['id']) ?? 0,
      name: _text(json['name']) ?? '',
      slug: _text(json['slug']) ?? '',
      services: _list(json['services'])
          .map((item) => CleaningSpecialServiceConfigModel.fromJson(_map(item)))
          .toList(growable: false),
    );
  }
}

class CleaningSpecialServiceConfigModel {
  const CleaningSpecialServiceConfigModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.inputType = 'quantity',
    this.pricingUnit = 'item',
    this.unitCode,
    this.baseUnitPrice = 0,
    this.supportsDirtiness = true,
    this.genderConstraint,
    this.estimatedDurationMinutes = 30,
    this.requiresBeforeImage = false,
    this.requiresAfterImage = false,
    this.dirtinessLevels = const <CleaningDirtinessLevelConfigModel>[],
  });

  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String inputType;
  final String pricingUnit;
  final String? unitCode;
  final double baseUnitPrice;
  final bool supportsDirtiness;
  final String? genderConstraint;
  final int estimatedDurationMinutes;
  final bool requiresBeforeImage;
  final bool requiresAfterImage;
  final List<CleaningDirtinessLevelConfigModel> dirtinessLevels;

  factory CleaningSpecialServiceConfigModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CleaningSpecialServiceConfigModel(
      id: _integer(json['id']) ?? 0,
      name: _text(json['name']) ?? '',
      description: _text(json['description']),
      imageUrl: _text(json['imageUrl']),
      inputType: _text(json['inputType']) ?? 'quantity',
      pricingUnit: _text(json['pricingUnit']) ?? 'item',
      unitCode: _text(json['unitCode']),
      baseUnitPrice: _decimal(json['baseUnitPrice']) ?? 0,
      supportsDirtiness: _boolean(json['supportsDirtiness']) ?? true,
      genderConstraint: _text(json['genderConstraint']),
      estimatedDurationMinutes:
          _integer(json['estimatedDurationMinutes']) ?? 30,
      requiresBeforeImage: _boolean(json['requiresBeforeImage']) ?? false,
      requiresAfterImage: _boolean(json['requiresAfterImage']) ?? false,
      dirtinessLevels: _list(json['dirtinessLevels'])
          .map((item) => CleaningDirtinessLevelConfigModel.fromJson(_map(item)))
          .toList(growable: false),
    );
  }
}

class CleaningEventTypeConfigModel {
  const CleaningEventTypeConfigModel({
    required this.id,
    required this.name,
    required this.slug,
    this.fields = const <CleaningDynamicFieldConfigModel>[],
    this.specialServiceIds = const <int>[],
  });

  final int id;
  final String name;
  final String slug;
  final List<CleaningDynamicFieldConfigModel> fields;
  final List<int> specialServiceIds;

  factory CleaningEventTypeConfigModel.fromJson(Map<String, dynamic> json) {
    return CleaningEventTypeConfigModel(
      id: _integer(json['id']) ?? 0,
      name: _text(json['name']) ?? '',
      slug: _text(json['slug']) ?? '',
      fields: _list(json['fields'])
          .map((item) => CleaningDynamicFieldConfigModel.fromJson(_map(item)))
          .toList(growable: false),
      specialServiceIds: _list(
        json['specialServiceIds'],
      ).map(_integer).whereType<int>().toList(growable: false),
    );
  }
}

class CleaningDynamicFieldConfigModel {
  const CleaningDynamicFieldConfigModel({
    required this.id,
    required this.key,
    required this.label,
    required this.type,
    this.required = false,
    this.options = const <dynamic>[],
  });

  final int id;
  final String key;
  final String label;
  final String type;
  final bool required;
  final List<dynamic> options;

  factory CleaningDynamicFieldConfigModel.fromJson(Map<String, dynamic> json) {
    return CleaningDynamicFieldConfigModel(
      id: _integer(json['id']) ?? 0,
      key: _text(json['key']) ?? '',
      label: _text(json['label']) ?? '',
      type: _text(json['type']) ?? 'text',
      required: _boolean(json['required']) ?? false,
      options: _list(json['options']),
    );
  }
}

Map<String, dynamic> _map(dynamic value) {
  if (value is! Map) return const <String, dynamic>{};
  return value.map((key, item) => MapEntry(key.toString(), item));
}

List<dynamic> _list(dynamic value) => value is List ? value : const <dynamic>[];

String? _text(dynamic value) {
  final result = value?.toString().trim();
  return result == null || result.isEmpty ? null : result;
}

int? _integer(dynamic value) =>
    value is num ? value.toInt() : int.tryParse(value?.toString() ?? '');

double? _decimal(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '');

bool? _boolean(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value == 1 ? true : (value == 0 ? false : null);
  return switch (value?.toString().trim().toLowerCase()) {
    'true' || '1' => true,
    'false' || '0' => false,
    _ => null,
  };
}
