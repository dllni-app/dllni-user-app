import 'package:dllni_user_app/core/models/cleaning_gender_preference.dart';

import 'cleaning_booking_status.dart';

import 'orders_api_models.dart';

Map<String, dynamic> _toMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  return <String, dynamic>{};
}

List<Map<String, dynamic>> _toMapList(dynamic value) {
  if (value is List) {
    return value.map((item) => _toMap(item)).toList(growable: false);
  }
  return const <Map<String, dynamic>>[];
}

List<dynamic>? _toDynamicList(dynamic value) {
  if (value is! List) return null;
  return value
      .map((item) {
        if (item is Map) return _toMap(item);
        return item;
      })
      .toList(growable: false);
}

int? _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

double? _toDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

String? _toStringValue(dynamic value) {
  if (value == null) return null;
  final text = value.toString();
  return text.isEmpty ? null : text;
}

dynamic _pick(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    if (!map.containsKey(key)) continue;
    final value = map[key];
    if (value != null) return value;
  }
  return null;
}

Map<String, dynamic> _withTracking(Map<String, dynamic> json) {
  final tracking = json['tracking'];
  if (tracking is Map) {
    return {...json, ..._toMap(tracking)};
  }
  return json;
}

/// Arabic status chip/label for cleaning orders (list + details).
String cleaningOrderStatusLabelAr(String? status) {
  switch ((status ?? '').toLowerCase()) {
    case CleaningBookingStatus.pending:
      return 'في مرحلة الاستعداد';
    case CleaningBookingStatus.workerAssigned:
      return 'تم تعيين مقدم الخدمة';
    case CleaningBookingStatus.awaitingStartVerification:
      return 'بانتظار رمز التحقق';
    case CleaningBookingStatus.inProgress:
      return 'قيد التنفيذ';
    case CleaningBookingStatus.awaitingCustomerCompletion:
      return 'بانتظار تأكيد الإكمال';
    case CleaningBookingStatus.timeExtensionRequested:
      return 'طلب تمديد الوقت';
    case CleaningBookingStatus.completed:
      return 'مكتمل';
    case CleaningBookingStatus.cancelled:
      return 'ملغي';
    default:
      return 'قيد المعالجة';
  }
}

FetchCleaningOrdersModel fetchCleaningOrdersModelFromJson(dynamic json) {
  return FetchCleaningOrdersModel.fromJson(_toMap(json));
}

FetchCleaningOrderDetailsModel fetchCleaningOrderDetailsModelFromJson(
  dynamic json,
) {
  return FetchCleaningOrderDetailsModel.fromJson(_toMap(json));
}

class FetchCleaningOrdersModel {
  final List<CleaningOrderModel> data;
  final OrdersMetaModel? meta;
  final OrdersLinksModel? links;

  FetchCleaningOrdersModel({required this.data, this.meta, this.links});

  factory FetchCleaningOrdersModel.fromJson(Map<String, dynamic> json) {
    return FetchCleaningOrdersModel(
      data: _toMapList(json['data']).map(CleaningOrderModel.fromJson).toList(),
      meta: json['meta'] == null
          ? null
          : OrdersMetaModel.fromJson(_toMap(json['meta'])),
      links: json['links'] == null
          ? null
          : OrdersLinksModel.fromJson(_toMap(json['links'])),
    );
  }
}

class FetchCleaningOrderDetailsModel {
  final CleaningOrderDetailModel? data;

  FetchCleaningOrderDetailsModel({this.data});

  factory FetchCleaningOrderDetailsModel.fromJson(Map<String, dynamic> json) {
    return FetchCleaningOrderDetailsModel(
      data: json['data'] == null
          ? null
          : CleaningOrderDetailModel.fromJson(_toMap(json['data'])),
    );
  }
}

class CleaningOrderModel {
  final int? id;
  final int? customerId;
  final int? workerId;
  final String? bookingNumber;
  final String? status;
  final String? propertyType;
  final CleaningPropertyDetailsModel? propertyDetails;
  final double? addressLatitude;
  final double? addressLongitude;
  final String? locationName;
  final String? estimatedSqm;
  final String? estimatedHours;
  final double? totalHours;
  final double? basePrice;
  final double? addonsTotal;
  final double? travelFee;
  final double? cancellationFee;
  final double? totalPrice;
  final String? scheduledDate;
  final String? scheduledTime;
  final CleaningGenderPreference genderPreference;
  final String? startedTravelAt;
  final String? arrivedAt;
  final String? workStartedAt;
  final String? workFinishedAt;
  final String? customerConfirmedAt;
  final String? cancelledAt;
  final CleaningOrderCustomerModel? customer;
  final CleaningOrderWorkerModel? worker;
  final List<CleaningOrderLineItemModel>? services;
  final List<CleaningOrderLineItemModel>? addons;
  final Map<String, dynamic>? billingPolicy;
  final List<dynamic>? timeWarnings;
  final List<dynamic>? disputes;

  CleaningOrderModel({
    this.id,
    this.customerId,
    this.workerId,
    this.bookingNumber,
    this.status,
    this.propertyType,
    this.propertyDetails,
    this.addressLatitude,
    this.addressLongitude,
    this.locationName,
    this.estimatedSqm,
    this.estimatedHours,
    this.totalHours,
    this.basePrice,
    this.addonsTotal,
    this.travelFee,
    this.cancellationFee,
    this.totalPrice,
    this.scheduledDate,
    this.scheduledTime,
    this.genderPreference = CleaningGenderPreference.any,
    this.startedTravelAt,
    this.arrivedAt,
    this.workStartedAt,
    this.workFinishedAt,
    this.customerConfirmedAt,
    this.cancelledAt,
    this.customer,
    this.worker,
    this.services,
    this.addons,
    this.billingPolicy,
    this.timeWarnings,
    this.disputes,
  });

  factory CleaningOrderModel.fromJson(Map<String, dynamic> json) {
    final m = _withTracking(json);
    return CleaningOrderModel(
      id: _toInt(_pick(m, const <String>['id'])),
      customerId: _toInt(_pick(m, const <String>['customerId', 'customer_id'])),
      workerId: _toInt(_pick(m, const <String>['workerId', 'worker_id'])),
      bookingNumber: _toStringValue(
        _pick(m, const <String>['bookingNumber', 'booking_number']),
      ),
      status: _toStringValue(_pick(m, const <String>['status'])),
      propertyType: _toStringValue(
        _pick(m, const <String>['propertyType', 'property_type']),
      ),
      propertyDetails: m['propertyDetails'] == null
          ? null
          : CleaningPropertyDetailsModel.fromJson(_toMap(m['propertyDetails'])),
      addressLatitude: _toDouble(
        _pick(m, const <String>[
          'addressLatitude',
          'address_latitude',
          'latitude',
        ]),
      ),
      addressLongitude: _toDouble(
        _pick(m, const <String>[
          'addressLongitude',
          'address_longitude',
          'longitude',
        ]),
      ),
      locationName: _toStringValue(
        _pick(m, const <String>['locationName', 'location_name']),
      ),
      estimatedSqm: _toStringValue(
        _pick(m, const <String>['estimatedSqm', 'estimated_sqm']),
      ),
      estimatedHours: _toStringValue(
        _pick(m, const <String>['estimatedHours', 'estimated_hours']),
      ),
      totalHours: _toDouble(
        _pick(m, const <String>['totalHours', 'total_hours']),
      ),
      basePrice: _toDouble(_pick(m, const <String>['basePrice', 'base_price'])),
      addonsTotal: _toDouble(
        _pick(m, const <String>['addonsTotal', 'addons_total']),
      ),
      travelFee: _toDouble(_pick(m, const <String>['travelFee', 'travel_fee'])),
      cancellationFee: _toDouble(
        _pick(m, const <String>['cancellationFee', 'cancellation_fee']),
      ),
      totalPrice: _toDouble(
        _pick(m, const <String>['totalPrice', 'total_price']),
      ),
      scheduledDate: _toStringValue(
        _pick(m, const <String>['scheduledDate', 'scheduled_date']),
      ),
      scheduledTime: _toStringValue(
        _pick(m, const <String>['scheduledTime', 'scheduled_time']),
      ),
      genderPreference: CleaningGenderPreference.fromApi(
        _toStringValue(
          _pick(m, const <String>['genderPreference', 'gender_preference']),
        ),
      ),
      startedTravelAt: _toStringValue(
        _pick(m, const <String>['startedTravelAt', 'started_travel_at']),
      ),
      arrivedAt: _toStringValue(
        _pick(m, const <String>['arrivedAt', 'arrived_at']),
      ),
      workStartedAt: _toStringValue(
        _pick(m, const <String>['workStartedAt', 'work_started_at']),
      ),
      workFinishedAt: _toStringValue(
        _pick(m, const <String>['workFinishedAt', 'work_finished_at']),
      ),
      customerConfirmedAt: _toStringValue(
        _pick(m, const <String>[
          'customerConfirmedAt',
          'customer_confirmed_at',
        ]),
      ),
      cancelledAt: _toStringValue(
        _pick(m, const <String>['cancelledAt', 'cancelled_at']),
      ),
      customer: m['customer'] == null
          ? null
          : CleaningOrderCustomerModel.fromJson(_toMap(m['customer'])),
      worker: m['worker'] == null
          ? null
          : CleaningOrderWorkerModel.fromJson(_toMap(m['worker'])),
      services: _toMapList(
        m['services'],
      ).map(CleaningOrderLineItemModel.fromJson).toList(growable: false),
      addons: _toMapList(
        m['addons'],
      ).map(CleaningOrderLineItemModel.fromJson).toList(growable: false),
      billingPolicy: m['billingPolicy'] is Map
          ? _toMap(m['billingPolicy'])
          : (m['billing_policy'] is Map ? _toMap(m['billing_policy']) : null),
      timeWarnings: _toDynamicList(m['timeWarnings'] ?? m['time_warnings']),
      disputes: _toDynamicList(m['disputes']),
    );
  }
}

class CleaningOrderDetailModel {
  final int? id;
  final int? customerId;
  final int? workerId;
  final String? bookingNumber;
  final String? status;
  final String? propertyType;
  final CleaningPropertyDetailsModel? propertyDetails;
  final double? addressLatitude;
  final double? addressLongitude;
  final String? locationName;
  final int? numberOfRooms;
  final int? numberOfKitchens;
  final String? estimatedSqm;
  final String? estimatedHours;
  final double? totalHours;
  final double? basePrice;
  final double? addonsTotal;
  final double? travelFee;
  final double? cancellationFee;
  final double? totalPrice;
  final String? scheduledDate;
  final String? scheduledTime;
  final CleaningGenderPreference genderPreference;
  final String? startedTravelAt;
  final String? arrivedAt;
  final String? workStartedAt;
  final String? workFinishedAt;
  final String? customerConfirmedAt;
  final String? cancelledAt;
  final CleaningOrderCustomerModel? customer;
  final CleaningOrderWorkerModel? worker;
  final List<CleaningOrderLineItemModel>? services;
  final List<CleaningOrderLineItemModel>? addons;
  final Map<String, dynamic>? billingPolicy;
  final List<dynamic>? timeWarnings;
  final List<dynamic>? disputes;

  CleaningOrderDetailModel({
    this.id,
    this.customerId,
    this.workerId,
    this.bookingNumber,
    this.status,
    this.propertyType,
    this.propertyDetails,
    this.addressLatitude,
    this.addressLongitude,
    this.locationName,
    this.numberOfRooms,
    this.numberOfKitchens,
    this.estimatedSqm,
    this.estimatedHours,
    this.totalHours,
    this.basePrice,
    this.addonsTotal,
    this.travelFee,
    this.cancellationFee,
    this.totalPrice,
    this.scheduledDate,
    this.scheduledTime,
    this.genderPreference = CleaningGenderPreference.any,
    this.startedTravelAt,
    this.arrivedAt,
    this.workStartedAt,
    this.workFinishedAt,
    this.customerConfirmedAt,
    this.cancelledAt,
    this.customer,
    this.worker,
    this.services,
    this.addons,
    this.billingPolicy,
    this.timeWarnings,
    this.disputes,
  });

  factory CleaningOrderDetailModel.fromJson(Map<String, dynamic> json) {
    final m = _withTracking(json);
    return CleaningOrderDetailModel(
      id: _toInt(_pick(m, const <String>['id'])),
      customerId: _toInt(_pick(m, const <String>['customerId', 'customer_id'])),
      workerId: _toInt(_pick(m, const <String>['workerId', 'worker_id'])),
      bookingNumber: _toStringValue(
        _pick(m, const <String>['bookingNumber', 'booking_number']),
      ),
      status: _toStringValue(_pick(m, const <String>['status'])),
      propertyType: _toStringValue(
        _pick(m, const <String>['propertyType', 'property_type']),
      ),
      propertyDetails: m['propertyDetails'] == null
          ? null
          : CleaningPropertyDetailsModel.fromJson(_toMap(m['propertyDetails'])),
      addressLatitude: _toDouble(
        _pick(m, const <String>[
          'addressLatitude',
          'address_latitude',
          'latitude',
        ]),
      ),
      addressLongitude: _toDouble(
        _pick(m, const <String>[
          'addressLongitude',
          'address_longitude',
          'longitude',
        ]),
      ),
      locationName: _toStringValue(
        _pick(m, const <String>['locationName', 'location_name']),
      ),
      numberOfRooms: _toInt(
        _pick(m, const <String>['numberOfRooms', 'number_of_rooms']),
      ),
      numberOfKitchens: _toInt(
        _pick(m, const <String>['numberOfKitchens', 'number_of_kitchens']),
      ),
      estimatedSqm: _toStringValue(
        _pick(m, const <String>['estimatedSqm', 'estimated_sqm']),
      ),
      estimatedHours: _toStringValue(
        _pick(m, const <String>['estimatedHours', 'estimated_hours']),
      ),
      totalHours: _toDouble(
        _pick(m, const <String>['totalHours', 'total_hours']),
      ),
      basePrice: _toDouble(_pick(m, const <String>['basePrice', 'base_price'])),
      addonsTotal: _toDouble(
        _pick(m, const <String>['addonsTotal', 'addons_total']),
      ),
      travelFee: _toDouble(_pick(m, const <String>['travelFee', 'travel_fee'])),
      cancellationFee: _toDouble(
        _pick(m, const <String>['cancellationFee', 'cancellation_fee']),
      ),
      totalPrice: _toDouble(
        _pick(m, const <String>['totalPrice', 'total_price']),
      ),
      scheduledDate: _toStringValue(
        _pick(m, const <String>['scheduledDate', 'scheduled_date']),
      ),
      scheduledTime: _toStringValue(
        _pick(m, const <String>['scheduledTime', 'scheduled_time']),
      ),
      genderPreference: CleaningGenderPreference.fromApi(
        _toStringValue(
          _pick(m, const <String>['genderPreference', 'gender_preference']),
        ),
      ),
      startedTravelAt: _toStringValue(
        _pick(m, const <String>['startedTravelAt', 'started_travel_at']),
      ),
      arrivedAt: _toStringValue(
        _pick(m, const <String>['arrivedAt', 'arrived_at']),
      ),
      workStartedAt: _toStringValue(
        _pick(m, const <String>['workStartedAt', 'work_started_at']),
      ),
      workFinishedAt: _toStringValue(
        _pick(m, const <String>['workFinishedAt', 'work_finished_at']),
      ),
      customerConfirmedAt: _toStringValue(
        _pick(m, const <String>[
          'customerConfirmedAt',
          'customer_confirmed_at',
        ]),
      ),
      cancelledAt: _toStringValue(
        _pick(m, const <String>['cancelledAt', 'cancelled_at']),
      ),
      customer: m['customer'] == null
          ? null
          : CleaningOrderCustomerModel.fromJson(_toMap(m['customer'])),
      worker: m['worker'] == null
          ? null
          : CleaningOrderWorkerModel.fromJson(_toMap(m['worker'])),
      services: _toMapList(
        m['services'],
      ).map(CleaningOrderLineItemModel.fromJson).toList(growable: false),
      addons: _toMapList(
        m['addons'],
      ).map(CleaningOrderLineItemModel.fromJson).toList(growable: false),
      billingPolicy: m['billingPolicy'] is Map
          ? _toMap(m['billingPolicy'])
          : (m['billing_policy'] is Map ? _toMap(m['billing_policy']) : null),
      timeWarnings: _toDynamicList(m['timeWarnings'] ?? m['time_warnings']),
      disputes: _toDynamicList(m['disputes']),
    );
  }

  CleaningOrderModel toCleaningOrderModel() {
    return CleaningOrderModel(
      id: id,
      customerId: customerId,
      workerId: workerId,
      bookingNumber: bookingNumber,
      status: status,
      propertyType: propertyType,
      propertyDetails: propertyDetails,
      addressLatitude: addressLatitude,
      addressLongitude: addressLongitude,
      locationName: locationName,
      estimatedSqm: estimatedSqm,
      estimatedHours: estimatedHours,
      totalHours: totalHours,
      basePrice: basePrice,
      addonsTotal: addonsTotal,
      travelFee: travelFee,
      cancellationFee: cancellationFee,
      totalPrice: totalPrice,
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
      genderPreference: genderPreference,
      startedTravelAt: startedTravelAt,
      arrivedAt: arrivedAt,
      workStartedAt: workStartedAt,
      workFinishedAt: workFinishedAt,
      customerConfirmedAt: customerConfirmedAt,
      cancelledAt: cancelledAt,
      customer: customer,
      worker: worker,
      services: services,
      addons: addons,
      billingPolicy: billingPolicy,
      timeWarnings: timeWarnings,
      disputes: disputes,
    );
  }
}

class CleaningOrderWorkerModel {
  final int? id;
  final String? name;
  final String? phone;
  final double? averageRating;
  final String? avatarUrl;

  CleaningOrderWorkerModel({
    this.id,
    this.name,
    this.phone,
    this.averageRating,
    this.avatarUrl,
  });

  factory CleaningOrderWorkerModel.fromJson(Map<String, dynamic> json) {
    return CleaningOrderWorkerModel(
      id: _toInt(_pick(json, const <String>['id'])),
      name: _toStringValue(
        _pick(json, const <String>['name', 'firstName', 'first_name']),
      ),
      phone: _toStringValue(_pick(json, const <String>['phone'])),
      averageRating: _toDouble(
        _pick(json, const <String>['averageRating', 'average_rating']),
      ),
      avatarUrl: _toStringValue(
        _pick(json, const <String>['avatarUrl', 'avatar_url']),
      ),
    );
  }
}

class CleaningOrderCustomerModel {
  final int? id;
  final String? name;
  final String? phone;
  final String? email;

  CleaningOrderCustomerModel({this.id, this.name, this.phone, this.email});

  factory CleaningOrderCustomerModel.fromJson(Map<String, dynamic> json) {
    return CleaningOrderCustomerModel(
      id: _toInt(_pick(json, const <String>['id'])),
      name: _toStringValue(_pick(json, const <String>['name'])),
      phone: _toStringValue(_pick(json, const <String>['phone'])),
      email: _toStringValue(_pick(json, const <String>['email'])),
    );
  }
}

class CleaningOrderLineItemModel {
  final int? id;
  final String? name;
  final int? quantity;

  CleaningOrderLineItemModel({this.id, this.name, this.quantity});

  factory CleaningOrderLineItemModel.fromJson(Map<String, dynamic> json) {
    return CleaningOrderLineItemModel(
      id: _toInt(_pick(json, const <String>['id'])),
      name: _toStringValue(_pick(json, const <String>['name'])),
      quantity: _toInt(_pick(json, const <String>['quantity'])),
    );
  }
}

class CleaningPropertyDetailsModel {
  final String? address;
  final String? locationName;
  final int? bedrooms;
  final int? rooms;
  final int? bathrooms;
  final int? kitchens;
  final String? livingRoomSize;

  CleaningPropertyDetailsModel({
    this.address,
    this.locationName,
    this.bedrooms,
    this.rooms,
    this.bathrooms,
    this.kitchens,
    this.livingRoomSize,
  });

  factory CleaningPropertyDetailsModel.fromJson(Map<String, dynamic> json) {
    return CleaningPropertyDetailsModel(
      address: _toStringValue(_pick(json, const <String>['address'])),
      locationName: _toStringValue(
        _pick(json, const <String>['location_name', 'locationName']),
      ),
      bedrooms: _toInt(_pick(json, const <String>['bedrooms'])),
      rooms: _toInt(_pick(json, const <String>['rooms'])),
      bathrooms: _toInt(_pick(json, const <String>['bathrooms'])),
      kitchens: _toInt(
        _pick(json, const <String>['kitchens', 'kitchen_included']),
      ),
      livingRoomSize: _toStringValue(
        _pick(json, const <String>['living_room_size', 'livingRoomSize']),
      ),
    );
  }
}
