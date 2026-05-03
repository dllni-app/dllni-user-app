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
    return value.map((item) => _toMap(item)).toList();
  }
  return const <Map<String, dynamic>>[];
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

/// Merges `tracking` into the root map when the API nests lifecycle timestamps.
Map<String, dynamic> _cleaningDetailJsonMap(Map<String, dynamic> json) {
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
  final String? bookingNumber;
  final String? status;
  final String? propertyType;
  final double? totalPrice;
  final String? scheduledDate;
  final String? scheduledTime;
  final double? addressLatitude;
  final double? addressLongitude;
  final String? locationName;
  final CleaningPropertyDetailsModel? propertyDetails;

  CleaningOrderModel({
    this.id,
    this.bookingNumber,
    this.status,
    this.propertyType,
    this.totalPrice,
    this.scheduledDate,
    this.scheduledTime,
    this.addressLatitude,
    this.addressLongitude,
    this.locationName,
    this.propertyDetails,
  });

  factory CleaningOrderModel.fromJson(Map<String, dynamic> json) {
    return CleaningOrderModel(
      id: _toInt(json['id']),
      bookingNumber: _toStringValue(json['bookingNumber']),
      status: _toStringValue(json['status']),
      propertyType: _toStringValue(json['propertyType']),
      totalPrice: _toDouble(json['totalPrice']),
      scheduledDate: _toStringValue(json['scheduledDate']),
      scheduledTime: _toStringValue(json['scheduledTime']),
      addressLatitude: _toDouble(
        json['addressLatitude'] ?? json['address_latitude'] ?? json['latitude'],
      ),
      addressLongitude: _toDouble(
        json['addressLongitude'] ??
            json['address_longitude'] ??
            json['longitude'],
      ),
      locationName: _toStringValue(json['locationName']),
      propertyDetails: json['propertyDetails'] == null
          ? null
          : CleaningPropertyDetailsModel.fromJson(
              _toMap(json['propertyDetails']),
            ),
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
  final String? scheduledDate;
  final String? scheduledTime;
  final double? basePrice;
  final double? addonsTotal;
  final double? travelFee;
  final double? totalPrice;
  final CleaningOrderWorkerModel? worker;
  final String? startedTravelAt;
  final String? arrivedAt;
  final String? workStartedAt;
  final String? workFinishedAt;
  final String? customerConfirmedAt;
  final String? cancelledAt;

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
    this.scheduledDate,
    this.scheduledTime,
    this.basePrice,
    this.addonsTotal,
    this.travelFee,
    this.totalPrice,
    this.worker,
    this.startedTravelAt,
    this.arrivedAt,
    this.workStartedAt,
    this.workFinishedAt,
    this.customerConfirmedAt,
    this.cancelledAt,
  });

  factory CleaningOrderDetailModel.fromJson(Map<String, dynamic> json) {
    final m = _cleaningDetailJsonMap(json);
    return CleaningOrderDetailModel(
      id: _toInt(m['id'] ?? json['id']),
      customerId: _toInt(m['customerId'] ?? json['customerId']),
      workerId: _toInt(m['workerId'] ?? json['workerId']),
      bookingNumber: _toStringValue(
        m['bookingNumber'] ?? json['bookingNumber'],
      ),
      status: _toStringValue(m['status'] ?? json['status']),
      propertyType: _toStringValue(m['propertyType'] ?? json['propertyType']),
      propertyDetails: json['propertyDetails'] == null
          ? null
          : CleaningPropertyDetailsModel.fromJson(
              _toMap(json['propertyDetails']),
            ),
      addressLatitude: _toDouble(
        m['addressLatitude'] ??
            m['address_latitude'] ??
            m['latitude'] ??
            json['addressLatitude'] ??
            json['address_latitude'] ??
            json['latitude'],
      ),
      addressLongitude: _toDouble(
        m['addressLongitude'] ??
            m['address_longitude'] ??
            m['longitude'] ??
            json['addressLongitude'] ??
            json['address_longitude'] ??
            json['longitude'],
      ),
      locationName: _toStringValue(m['locationName'] ?? json['locationName']),
      numberOfRooms: _toInt(m['numberOfRooms'] ?? json['numberOfRooms']),
      numberOfKitchens: _toInt(
        m['numberOfKitchens'] ?? json['numberOfKitchens'],
      ),
      estimatedSqm: _toStringValue(m['estimatedSqm'] ?? json['estimatedSqm']),
      estimatedHours: _toStringValue(
        m['estimatedHours'] ?? json['estimatedHours'],
      ),
      totalHours: _toDouble(m['totalHours'] ?? json['totalHours']),
      scheduledDate: _toStringValue(
        m['scheduledDate'] ?? json['scheduledDate'],
      ),
      scheduledTime: _toStringValue(
        m['scheduledTime'] ?? json['scheduledTime'],
      ),
      basePrice: _toDouble(m['basePrice'] ?? json['basePrice']),
      addonsTotal: _toDouble(m['addonsTotal'] ?? json['addonsTotal']),
      travelFee: _toDouble(m['travelFee'] ?? json['travelFee']),
      totalPrice: _toDouble(m['totalPrice'] ?? json['totalPrice']),
      worker: json['worker'] == null
          ? null
          : CleaningOrderWorkerModel.fromJson(_toMap(json['worker'])),
      startedTravelAt: _toStringValue(
        m['startedTravelAt'] ?? json['startedTravelAt'],
      ),
      arrivedAt: _toStringValue(m['arrivedAt'] ?? json['arrivedAt']),
      workStartedAt: _toStringValue(
        m['workStartedAt'] ?? json['workStartedAt'],
      ),
      workFinishedAt: _toStringValue(
        m['workFinishedAt'] ?? json['workFinishedAt'],
      ),
      customerConfirmedAt: _toStringValue(
        m['customerConfirmedAt'] ?? json['customerConfirmedAt'],
      ),
      cancelledAt: _toStringValue(m['cancelledAt'] ?? json['cancelledAt']),
    );
  }

  CleaningOrderModel toCleaningOrderModel() {
    return CleaningOrderModel(
      id: id,
      bookingNumber: bookingNumber,
      status: status,
      propertyType: propertyType,
      totalPrice: totalPrice,
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
      addressLatitude: addressLatitude,
      addressLongitude: addressLongitude,
      locationName: locationName,
      propertyDetails: propertyDetails,
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
      id: _toInt(json['id']),
      name: _toStringValue(json['name']) ?? _toStringValue(json['firstName']),
      phone: _toStringValue(json['phone']),
      averageRating: _toDouble(json['averageRating']),
      avatarUrl: _toStringValue(json['avatarUrl']),
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
      address: _toStringValue(json['address']),
      locationName: _toStringValue(json['location_name']),
      bedrooms: _toInt(json['bedrooms']),
      rooms: _toInt(json['rooms']),
      bathrooms: _toInt(json['bathrooms']),
      kitchens: _toInt(json['kitchens']),
      livingRoomSize: _toStringValue(json['living_room_size']),
    );
  }
}
