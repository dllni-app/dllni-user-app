import '../../../orders/data/models/orders_api_models.dart';

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((k, v) => MapEntry('$k', v));
  return <String, dynamic>{};
}

List<Map<String, dynamic>> _asMapList(dynamic value) {
  if (value is! List) return const <Map<String, dynamic>>[];
  return value.whereType<Map>().map((item) => _asMap(item)).toList();
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value');
}

double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse('$value');
}

String? _asString(dynamic value) {
  if (value == null) return null;
  return '$value';
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.toLowerCase();
    return normalized == '1' || normalized == 'true';
  }
  return false;
}

dynamic _readKey(
  Map<String, dynamic> json,
  String camelKey, [
  String? snakeKey,
]) {
  if (json.containsKey(camelKey)) return json[camelKey];
  if (snakeKey != null && json.containsKey(snakeKey)) return json[snakeKey];
  return null;
}

FetchShoppingListsModel fetchShoppingListsModelFromJson(dynamic json) =>
    FetchShoppingListsModel.fromJson(_asMap(json));

ShoppingListDetailResponseModel shoppingListDetailResponseModelFromJson(
  dynamic json,
) => ShoppingListDetailResponseModel.fromJson(_asMap(json));

FetchRestaurantCartModel addShoppingListToCartModelFromJson(dynamic json) =>
    fetchRestaurantCartModelFromJson(json);

class FetchShoppingListsModel {
  final List<ShoppingListSummaryModel> data;

  const FetchShoppingListsModel({this.data = const <ShoppingListSummaryModel>[]});

  factory FetchShoppingListsModel.fromJson(Map<String, dynamic> json) {
    return FetchShoppingListsModel(
      data: _asMapList(json['data']).map(ShoppingListSummaryModel.fromJson).toList(),
    );
  }
}

class ShoppingListSummaryModel {
  final int id;
  final String name;
  final String? description;
  final bool isActive;
  final int itemsCount;
  final String? createdAt;
  final String? updatedAt;

  const ShoppingListSummaryModel({
    this.id = 0,
    this.name = '',
    this.description,
    this.isActive = true,
    this.itemsCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory ShoppingListSummaryModel.fromJson(Map<String, dynamic> json) {
    return ShoppingListSummaryModel(
      id: _asInt(_readKey(json, 'id')) ?? 0,
      name: _asString(_readKey(json, 'name')) ?? '',
      description: _asString(_readKey(json, 'description')),
      isActive: _asBool(_readKey(json, 'isActive', 'is_active')),
      itemsCount: _asInt(_readKey(json, 'itemsCount', 'items_count')) ?? 0,
      createdAt: _asString(_readKey(json, 'createdAt', 'created_at')),
      updatedAt: _asString(_readKey(json, 'updatedAt', 'updated_at')),
    );
  }
}

class ShoppingListDetailResponseModel {
  final ShoppingListDetailModel? data;

  const ShoppingListDetailResponseModel({this.data});

  factory ShoppingListDetailResponseModel.fromJson(Map<String, dynamic> json) {
    final payload = json['data'];
    return ShoppingListDetailResponseModel(
      data: payload is Map ? ShoppingListDetailModel.fromJson(_asMap(payload)) : null,
    );
  }
}

class ShoppingListDetailModel {
  final int id;
  final String name;
  final String? description;
  final bool isActive;
  final List<ShoppingListItemModel> items;
  final String? createdAt;
  final String? updatedAt;

  const ShoppingListDetailModel({
    this.id = 0,
    this.name = '',
    this.description,
    this.isActive = true,
    this.items = const <ShoppingListItemModel>[],
    this.createdAt,
    this.updatedAt,
  });

  factory ShoppingListDetailModel.fromJson(Map<String, dynamic> json) {
    return ShoppingListDetailModel(
      id: _asInt(_readKey(json, 'id')) ?? 0,
      name: _asString(_readKey(json, 'name')) ?? '',
      description: _asString(_readKey(json, 'description')),
      isActive: _asBool(_readKey(json, 'isActive', 'is_active')),
      items: _asMapList(json['items']).map(ShoppingListItemModel.fromJson).toList(),
      createdAt: _asString(_readKey(json, 'createdAt', 'created_at')),
      updatedAt: _asString(_readKey(json, 'updatedAt', 'updated_at')),
    );
  }

  ShoppingListDetailModel copyWith({
    String? name,
    String? description,
    bool? isActive,
    List<ShoppingListItemModel>? items,
    bool keepDescription = true,
  }) {
    return ShoppingListDetailModel(
      id: id,
      name: name ?? this.name,
      description: keepDescription ? (description ?? this.description) : description,
      isActive: isActive ?? this.isActive,
      items: items ?? this.items,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class ShoppingListItemModel {
  final int id;
  final int masterProductId;
  final String name;
  final double quantity;
  final String? unit;
  final int sortOrder;
  final bool isIncluded;
  final String? createdAt;
  final String? updatedAt;

  const ShoppingListItemModel({
    this.id = 0,
    this.masterProductId = 0,
    this.name = '',
    this.quantity = 1,
    this.unit,
    this.sortOrder = 0,
    this.isIncluded = true,
    this.createdAt,
    this.updatedAt,
  });

  factory ShoppingListItemModel.fromJson(Map<String, dynamic> json) {
    return ShoppingListItemModel(
      id: _asInt(_readKey(json, 'id')) ?? 0,
      masterProductId: _asInt(_readKey(json, 'masterProductId', 'master_product_id')) ?? 0,
      name: _asString(_readKey(json, 'name')) ?? '',
      quantity: _asDouble(_readKey(json, 'quantity')) ?? 1,
      unit: _asString(_readKey(json, 'unit')),
      sortOrder: _asInt(_readKey(json, 'sortOrder', 'sort_order')) ?? 0,
      isIncluded: _asBool(_readKey(json, 'isIncluded', 'is_included')),
      createdAt: _asString(_readKey(json, 'createdAt', 'created_at')),
      updatedAt: _asString(_readKey(json, 'updatedAt', 'updated_at')),
    );
  }

  ShoppingListItemModel copyWith({
    double? quantity,
    int? sortOrder,
    bool? isIncluded,
  }) {
    return ShoppingListItemModel(
      id: id,
      masterProductId: masterProductId,
      name: name,
      quantity: quantity ?? this.quantity,
      unit: unit,
      sortOrder: sortOrder ?? this.sortOrder,
      isIncluded: isIncluded ?? this.isIncluded,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class ShoppingListDetailsArgs {
  final int shoppingListId;
  final String? title;

  const ShoppingListDetailsArgs({required this.shoppingListId, this.title});
}
