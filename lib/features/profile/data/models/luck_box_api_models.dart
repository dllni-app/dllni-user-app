import 'package:common_package/helpers/typedef.dart';

int? _lbAsInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value');
}

String? _lbAsString(dynamic value) {
  if (value == null) return null;
  return '$value';
}

LuckBoxOptionsModel luckBoxOptionsModelFromJson(dynamic json) =>
    LuckBoxOptionsModel.fromJson(Map<String, dynamic>.from(json as Map));

LuckBoxSuggestResponseModel luckBoxSuggestResponseModelFromJson(dynamic json) =>
    LuckBoxSuggestResponseModel.fromJson(Map<String, dynamic>.from(json as Map));

Map<String, dynamic> _unwrapPayload(Map<String, dynamic> json) {
  if (json['data'] is Map) {
    return Map<String, dynamic>.from(json['data'] as Map);
  }
  return json;
}

class LuckBoxRestrictionOption {
  final String? value;
  final String? labelAr;

  const LuckBoxRestrictionOption({this.value, this.labelAr});

  factory LuckBoxRestrictionOption.fromJson(Map<String, dynamic> json) {
    return LuckBoxRestrictionOption(
      value: _lbAsString(json['value']),
      labelAr: _lbAsString(json['labelAr']),
    );
  }
}

class LuckBoxCuisineTypeOption {
  final int? id;
  final String? name;

  const LuckBoxCuisineTypeOption({this.id, this.name});

  factory LuckBoxCuisineTypeOption.fromJson(Map<String, dynamic> json) {
    return LuckBoxCuisineTypeOption(
      id: _lbAsInt(json['id']),
      name: _lbAsString(json['name']),
    );
  }
}

class LuckBoxOptionsModel {
  final List<LuckBoxRestrictionOption> restrictions;
  final List<LuckBoxCuisineTypeOption> cuisineTypes;

  const LuckBoxOptionsModel({
    this.restrictions = const [],
    this.cuisineTypes = const [],
  });

  factory LuckBoxOptionsModel.fromJson(Map<String, dynamic> json) {
    final payload = _unwrapPayload(json);
    return LuckBoxOptionsModel(
      restrictions: payload['restrictions'] is List
          ? (payload['restrictions'] as List)
              .whereType<Map>()
              .map((e) => LuckBoxRestrictionOption.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      cuisineTypes: payload['cuisineTypes'] is List
          ? (payload['cuisineTypes'] as List)
              .whereType<Map>()
              .map((e) => LuckBoxCuisineTypeOption.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }
}

class SuggestLuckBoxParams with Params {
  final int groupSize;
  final int budgetPerPerson;
  final List<String> restrictions;
  final double? latitude;
  final double? longitude;
  final int? cuisineTypeId;

  SuggestLuckBoxParams({
    required this.groupSize,
    required this.budgetPerPerson,
    required this.restrictions,
    this.latitude,
    this.longitude,
    this.cuisineTypeId,
  });

  Map<String, dynamic> toJson() => {
        'groupSize': groupSize,
        'budgetPerPerson': budgetPerPerson,
        'restrictions': restrictions,
        'latitude': latitude,
        'longitude': longitude,
        'cuisineTypeId': cuisineTypeId,
      };

  @override
  BodyMap getBody() => toJson();
}

class LuckBoxBudgetModel {
  final int? groupSize;
  final int? budgetPerPerson;
  final int? total;

  const LuckBoxBudgetModel({this.groupSize, this.budgetPerPerson, this.total});

  factory LuckBoxBudgetModel.fromJson(Map<String, dynamic> json) {
    return LuckBoxBudgetModel(
      groupSize: _lbAsInt(json['groupSize']),
      budgetPerPerson: _lbAsInt(json['budgetPerPerson']),
      total: _lbAsInt(json['total']),
    );
  }
}

class LuckBoxRestaurantModel {
  final int? id;
  final String? name;
  final String? slug;
  final String? primaryImageUrl;
  final String? bannerImageUrl;

  const LuckBoxRestaurantModel({
    this.id,
    this.name,
    this.slug,
    this.primaryImageUrl,
    this.bannerImageUrl,
  });

  factory LuckBoxRestaurantModel.fromJson(Map<String, dynamic> json) {
    return LuckBoxRestaurantModel(
      id: _lbAsInt(json['id']),
      name: _lbAsString(json['name']),
      slug: _lbAsString(json['slug']),
      primaryImageUrl: _lbAsString(json['primaryImageUrl']),
      bannerImageUrl: _lbAsString(json['bannerImageUrl']),
    );
  }
}

class LuckBoxLineItemModel {
  final int? productId;
  final String? name;
  final int? quantity;
  final int? unitPrice;
  final int? lineTotal;
  final String? imageUrl;

  const LuckBoxLineItemModel({
    this.productId,
    this.name,
    this.quantity,
    this.unitPrice,
    this.lineTotal,
    this.imageUrl,
  });

  factory LuckBoxLineItemModel.fromJson(Map<String, dynamic> json) {
    return LuckBoxLineItemModel(
      productId: _lbAsInt(json['productId']),
      name: _lbAsString(json['name']),
      quantity: _lbAsInt(json['quantity']),
      unitPrice: _lbAsInt(json['unitPrice']),
      lineTotal: _lbAsInt(json['lineTotal']),
      imageUrl: _lbAsString(json['imageUrl']),
    );
  }
}

class LuckBoxBundleModel {
  final String? label;
  final String? labelAr;
  final LuckBoxRestaurantModel? restaurant;
  final int? totalProducts;
  final String? itemsDescription;
  final int? totalPrice;
  final int? estimatedMinutes;
  final List<LuckBoxLineItemModel> lineItems;

  const LuckBoxBundleModel({
    this.label,
    this.labelAr,
    this.restaurant,
    this.totalProducts,
    this.itemsDescription,
    this.totalPrice,
    this.estimatedMinutes,
    this.lineItems = const [],
  });

  factory LuckBoxBundleModel.fromJson(Map<String, dynamic> json) {
    return LuckBoxBundleModel(
      label: _lbAsString(json['label']),
      labelAr: _lbAsString(json['labelAr']),
      restaurant: json['restaurant'] is Map
          ? LuckBoxRestaurantModel.fromJson(Map<String, dynamic>.from(json['restaurant'] as Map))
          : null,
      totalProducts: _lbAsInt(json['totalProducts']),
      itemsDescription: _lbAsString(json['itemsDescription']),
      totalPrice: _lbAsInt(json['totalPrice']),
      estimatedMinutes: _lbAsInt(json['estimatedMinutes']),
      lineItems: json['lineItems'] is List
          ? (json['lineItems'] as List)
              .whereType<Map>()
              .map((e) => LuckBoxLineItemModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }
}

class LuckBoxSuggestResponseModel {
  final LuckBoxBudgetModel? budget;
  final List<LuckBoxBundleModel> bundles;

  const LuckBoxSuggestResponseModel({
    this.budget,
    this.bundles = const [],
  });

  factory LuckBoxSuggestResponseModel.fromJson(Map<String, dynamic> json) {
    final payload = _unwrapPayload(json);
    return LuckBoxSuggestResponseModel(
      budget: payload['budget'] is Map
          ? LuckBoxBudgetModel.fromJson(Map<String, dynamic>.from(payload['budget'] as Map))
          : null,
      bundles: payload['bundles'] is List
          ? (payload['bundles'] as List)
              .whereType<Map>()
              .map((e) => LuckBoxBundleModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }
}
