import 'dart:convert';

String? _asString(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is num || value is bool) return value.toString();
  return null;
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? double.tryParse(value)?.toInt();
  }
  return null;
}

double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

num? _asNum(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}

bool? _asBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) {
    if (value == 1) return true;
    if (value == 0) return false;
  }
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }
  return null;
}

List<dynamic>? _asDynamicList(dynamic value) {
  if (value is! List) return null;
  return value.map(_asDynamic).toList();
}

dynamic _asDynamic(dynamic value) {
  if (value == null) return null;
  if (value is List) {
    return value.map(_asDynamic).toList();
  }
  if (value is Map) {
    final map = <String, dynamic>{};
    value.forEach((key, nestedValue) {
      map['$key'] = _asDynamic(nestedValue);
    });
    return map;
  }
  if (value is String || value is num || value is bool) {
    return value;
  }
  return value.toString();
}

GetShoppingListModel getShoppingListModelFromJson(str) => GetShoppingListModel.fromJson(str);

String getShoppingListModelToJson(GetShoppingListModel data) => json.encode(data.toJson());


GetShoppingListModelDataItem getShoppingListModelDataItemFromJson(str) => GetShoppingListModelDataItem.fromJson(str);

String getShoppingListModelDataItemToJson(GetShoppingListModelDataItem data) => json.encode(data.toJson());


GetShoppingListModelDataItemSchedule getShoppingListModelDataItemScheduleFromJson(str) => GetShoppingListModelDataItemSchedule.fromJson(str);

String getShoppingListModelDataItemScheduleToJson(GetShoppingListModelDataItemSchedule data) => json.encode(data.toJson());


GetShoppingListModelDataItemSchedulePeriodsItem getShoppingListModelDataItemSchedulePeriodsItemFromJson(str) => GetShoppingListModelDataItemSchedulePeriodsItem.fromJson(str);

String getShoppingListModelDataItemSchedulePeriodsItemToJson(GetShoppingListModelDataItemSchedulePeriodsItem data) => json.encode(data.toJson());


class GetShoppingListModel {
  List<GetShoppingListModelDataItem>? data;

  GetShoppingListModel({
    this.data,
  });

  factory GetShoppingListModel.fromJson(Map<String, dynamic> json) {
    return GetShoppingListModel(
      data: json['data'] is List ? (json['data'] as List).whereType<Map>().map((item) => GetShoppingListModelDataItem.fromJson(Map<String, dynamic>.from(item))).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.map((item) => item.toJson()).toList(),
    };
  }
}

class GetShoppingListModelDataItem {
  int? id;
  String? name;
  String? description;
  bool? isActive;
  GetShoppingListModelDataItemSchedule? schedule;
  int? itemsCount;
  String? createdAt;
  String? updatedAt;

  GetShoppingListModelDataItem({
    this.id,
    this.name,
    this.description,
    this.isActive,
    this.schedule,
    this.itemsCount,
    this.createdAt,
    this.updatedAt,
  });

  factory GetShoppingListModelDataItem.fromJson(Map<String, dynamic> json) {
    return GetShoppingListModelDataItem(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      description: _asString(json['description']),
      isActive: _asBool(json['isActive']),
      schedule: json['schedule'] is Map ? GetShoppingListModelDataItemSchedule.fromJson(Map<String, dynamic>.from(json['schedule'] as Map)) : null,
      itemsCount: _asInt(json['itemsCount']),
      createdAt: _asString(json['createdAt']),
      updatedAt: _asString(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isActive': isActive,
      'schedule': schedule?.toJson(),
      'itemsCount': itemsCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class GetShoppingListModelDataItemSchedule {
  String? frequencyType;
  List<int>? weekDays;
  List<dynamic>? monthDays;
  List<GetShoppingListModelDataItemSchedulePeriodsItem>? periods;
  bool? isActive;
  String? nextRunAt;
  dynamic lastRunAt;

  GetShoppingListModelDataItemSchedule({
    this.frequencyType,
    this.weekDays,
    this.monthDays,
    this.periods,
    this.isActive,
    this.nextRunAt,
    this.lastRunAt,
  });

  factory GetShoppingListModelDataItemSchedule.fromJson(Map<String, dynamic> json) {
    return GetShoppingListModelDataItemSchedule(
      frequencyType: _asString(json['frequencyType']),
      weekDays: json['weekDays'] is List ? (json['weekDays'] as List).map((item) => _asInt(item)).whereType<int>().toList() : null,
      monthDays: _asDynamicList(json['monthDays']),
      periods: json['periods'] is List ? (json['periods'] as List).whereType<Map>().map((item) => GetShoppingListModelDataItemSchedulePeriodsItem.fromJson(Map<String, dynamic>.from(item))).toList() : null,
      isActive: _asBool(json['isActive']),
      nextRunAt: _asString(json['nextRunAt']),
      lastRunAt: _asDynamic(json['lastRunAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'frequencyType': frequencyType,
      'weekDays': weekDays,
      'monthDays': monthDays,
      'periods': periods?.map((item) => item.toJson()).toList(),
      'isActive': isActive,
      'nextRunAt': nextRunAt,
      'lastRunAt': lastRunAt,
    };
  }
}

class GetShoppingListModelDataItemSchedulePeriodsItem {
  String? label;
  String? fromTime;
  String? toTime;

  GetShoppingListModelDataItemSchedulePeriodsItem({
    this.label,
    this.fromTime,
    this.toTime,
  });

  factory GetShoppingListModelDataItemSchedulePeriodsItem.fromJson(Map<String, dynamic> json) {
    return GetShoppingListModelDataItemSchedulePeriodsItem(
      label: _asString(json['label']),
      fromTime: _asString(json['fromTime']),
      toTime: _asString(json['toTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'fromTime': fromTime,
      'toTime': toTime,
    };
  }
}