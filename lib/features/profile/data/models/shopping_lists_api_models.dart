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

  const FetchShoppingListsModel({
    this.data = const <ShoppingListSummaryModel>[],
  });

  factory FetchShoppingListsModel.fromJson(Map<String, dynamic> json) {
    return FetchShoppingListsModel(
      data: _asMapList(
        json['data'],
      ).map(ShoppingListSummaryModel.fromJson).toList(),
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
      data: payload is Map
          ? ShoppingListDetailModel.fromJson(_asMap(payload))
          : null,
    );
  }
}

class ShoppingListDetailScheduleModel {
  final String? frequencyType;
  final List<int> weekDays;
  final List<dynamic> monthDays;
  final List<ShoppingListSchedulePeriodModel> periods;
  final bool isActive;
  final String? nextRunAt;
  final dynamic lastRunAt;

  const ShoppingListDetailScheduleModel({
    this.frequencyType,
    this.weekDays = const <int>[],
    this.monthDays = const <dynamic>[],
    this.periods = const <ShoppingListSchedulePeriodModel>[],
    this.isActive = true,
    this.nextRunAt,
    this.lastRunAt,
  });

  factory ShoppingListDetailScheduleModel.fromJson(Map<String, dynamic> json) {
    final weekRaw = json['weekDays'];
    final monthRaw = json['monthDays'];
    final periodsRaw = json['periods'];
    return ShoppingListDetailScheduleModel(
      frequencyType: _asString(
        _readKey(json, 'frequencyType', 'frequency_type'),
      ),
      weekDays: weekRaw is List
          ? weekRaw.map((e) => _asInt(e)).whereType<int>().toList()
          : const <int>[],
      monthDays: monthRaw is List ? monthRaw : const <dynamic>[],
      periods: periodsRaw is List
          ? periodsRaw
                .whereType<Map>()
                .map(
                  (e) => ShoppingListSchedulePeriodModel.fromJson(
                    _asMap(e),
                  ),
                )
                .toList()
          : const <ShoppingListSchedulePeriodModel>[],
      isActive: _asBool(_readKey(json, 'isActive', 'is_active')),
      nextRunAt: _asString(_readKey(json, 'nextRunAt', 'next_run_at')),
      lastRunAt: json.containsKey('lastRunAt')
          ? json['lastRunAt']
          : json['last_run_at'],
    );
  }
}

class ShoppingListSchedulePeriodModel {
  final String? label;
  final String? fromTime;
  final String? toTime;

  const ShoppingListSchedulePeriodModel({
    this.label,
    this.fromTime,
    this.toTime,
  });

  factory ShoppingListSchedulePeriodModel.fromJson(Map<String, dynamic> json) {
    return ShoppingListSchedulePeriodModel(
      label: _asString(_readKey(json, 'label')),
      fromTime: _asString(_readKey(json, 'fromTime', 'from_time')),
      toTime: _asString(_readKey(json, 'toTime', 'to_time')),
    );
  }
}

class ShoppingListDetailModel {
  final int id;
  final String name;
  final String? description;
  final bool isActive;
  final ShoppingListDetailScheduleModel? schedule;
  final List<ShoppingListItemModel> items;
  final String? createdAt;
  final String? updatedAt;

  const ShoppingListDetailModel({
    this.id = 0,
    this.name = '',
    this.description,
    this.isActive = true,
    this.schedule,
    this.items = const <ShoppingListItemModel>[],
    this.createdAt,
    this.updatedAt,
  });

  factory ShoppingListDetailModel.fromJson(Map<String, dynamic> json) {
    final schedulePayload = _readKey(json, 'schedule');
    return ShoppingListDetailModel(
      id: _asInt(_readKey(json, 'id')) ?? 0,
      name: _asString(_readKey(json, 'name')) ?? '',
      description: _asString(_readKey(json, 'description')),
      isActive: _asBool(_readKey(json, 'isActive', 'is_active')),
      schedule: schedulePayload is Map
          ? ShoppingListDetailScheduleModel.fromJson(_asMap(schedulePayload))
          : null,
      items: _asMapList(
        json['items'],
      ).map(ShoppingListItemModel.fromJson).toList(),
      createdAt: _asString(_readKey(json, 'createdAt', 'created_at')),
      updatedAt: _asString(_readKey(json, 'updatedAt', 'updated_at')),
    );
  }

  ShoppingListDetailModel copyWith({
    String? name,
    String? description,
    bool? isActive,
    ShoppingListDetailScheduleModel? schedule,
    List<ShoppingListItemModel>? items,
    bool keepDescription = true,
  }) {
    return ShoppingListDetailModel(
      id: id,
      name: name ?? this.name,
      description: keepDescription
          ? (description ?? this.description)
          : description,
      isActive: isActive ?? this.isActive,
      schedule: schedule ?? this.schedule,
      items: items ?? this.items,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class ShoppingListItemModel {
  int id;
  int masterProductId;
  String name;
  double quantity;
  String? unit;
  int sortOrder;
  bool isIncluded;
  String? createdAt;
  String? updatedAt;

  ShoppingListItemModel({
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
      masterProductId:
          _asInt(_readKey(json, 'masterProductId', 'master_product_id')) ?? 0,
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
