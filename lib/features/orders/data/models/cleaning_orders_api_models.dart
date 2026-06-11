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

bool? _toBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) {
    if (value == 1) return true;
    if (value == 0) return false;
  }
  final normalized = value?.toString().trim().toLowerCase();
  if (normalized == 'true' || normalized == '1') return true;
  if (normalized == 'false' || normalized == '0') return false;
  return null;
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
    case CleaningBookingStatus.awaitingWorkerStartConfirmation:
      return 'بانتظار تأكيد مقدم الخدمة لبدء العمل';
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
  final CleaningExtensionPricingModel? extensionPricing;
  final List<CleaningExtensionRangeModel> extendedTimeRanges;

  FetchCleaningOrderDetailsModel({
    this.data,
    this.extensionPricing,
    this.extendedTimeRanges = const <CleaningExtensionRangeModel>[],
  });

  factory FetchCleaningOrderDetailsModel.fromJson(Map<String, dynamic> json) {
    final data = _toMap(json['data']);
    return FetchCleaningOrderDetailsModel(
      data: data.isEmpty ? null : CleaningOrderDetailModel.fromJson(data),
      extensionPricing:
          json['extensionPricing'] == null && json['extension_pricing'] == null
          ? null
          : CleaningExtensionPricingModel.fromJson(
              _toMap(json['extensionPricing'] ?? json['extension_pricing']),
            ),
      extendedTimeRanges: _parseExtensionRanges(
        json['extendedTimeRanges'] ??
            json['extended_time_ranges'] ??
            data['extendedTimeRanges'] ??
            data['extended_time_ranges'],
      ),
    );
  }
}

List<CleaningExtensionRangeModel> _parseExtensionRanges(dynamic value) {
  if (value is! List) return const <CleaningExtensionRangeModel>[];
  return value
      .map((item) => CleaningExtensionRangeModel.fromJson(_toMap(item)))
      .where((item) => item.requestMinutes != null)
      .toList(growable: false);
}

class CleaningExtensionPricingModel {
  final int? requestedMinutes;
  final CleaningExtensionRangeModel? matchedRange;
  final double? calculatedExtensionPrice;
  final String? currency;

  CleaningExtensionPricingModel({
    this.requestedMinutes,
    this.matchedRange,
    this.calculatedExtensionPrice,
    this.currency,
  });

  factory CleaningExtensionPricingModel.fromJson(Map<String, dynamic> json) {
    return CleaningExtensionPricingModel(
      requestedMinutes: _toInt(
        _pick(json, const <String>['requestedMinutes', 'requested_minutes']),
      ),
      matchedRange:
          json['matchedRange'] == null && json['matched_range'] == null
          ? null
          : CleaningExtensionRangeModel.fromJson(
              _toMap(json['matchedRange'] ?? json['matched_range']),
            ),
      calculatedExtensionPrice: _toDouble(
        _pick(json, const <String>[
          'calculatedExtensionPrice',
          'calculated_extension_price',
        ]),
      ),
      currency: _toStringValue(_pick(json, const <String>['currency'])),
    );
  }
}

class CleaningExtensionRangeModel {
  final int? id;
  final int? startMinutes;
  final int? endMinutes;
  final String? label;
  final double? price;
  final String? currency;

  CleaningExtensionRangeModel({
    this.id,
    this.startMinutes,
    this.endMinutes,
    this.label,
    this.price,
    this.currency,
  });

  factory CleaningExtensionRangeModel.fromJson(Map<String, dynamic> json) {
    return CleaningExtensionRangeModel(
      id: _toInt(_pick(json, const <String>['id'])),
      startMinutes: _toInt(
        _pick(json, const <String>['startMinutes', 'start_minutes']),
      ),
      endMinutes: _toInt(
        _pick(json, const <String>['endMinutes', 'end_minutes']),
      ),
      label: _toStringValue(_pick(json, const <String>['label'])),
      price: _toDouble(_pick(json, const <String>['price'])),
      currency: _toStringValue(_pick(json, const <String>['currency'])),
    );
  }

  int? get requestMinutes => endMinutes ?? startMinutes;
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
  final double? travelDistanceKm;
  final double? adminMargin;
  final double? cancellationFee;
  final double? totalPrice;
  final bool? isPricingFinal;
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
  final String? assignmentMode;
  final int? numberOfWorkers;
  final CleaningWorkerAcceptanceModel? workerAcceptance;

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
    this.travelDistanceKm,
    this.adminMargin,
    this.cancellationFee,
    this.totalPrice,
    this.isPricingFinal,
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
    this.assignmentMode,
    this.numberOfWorkers,
    this.workerAcceptance,
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
      travelDistanceKm: _toDouble(
        _pick(m, const <String>['travelDistanceKm', 'travel_distance_km']),
      ),
      adminMargin: _toDouble(
        _pick(m, const <String>['adminMargin', 'admin_margin']),
      ),
      cancellationFee: _toDouble(
        _pick(m, const <String>['cancellationFee', 'cancellation_fee']),
      ),
      totalPrice: _toDouble(
        _pick(m, const <String>['totalPrice', 'total_price']),
      ),
      isPricingFinal: _toBool(
        _pick(m, const <String>['isPricingFinal', 'is_pricing_final']),
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
      assignmentMode: _toStringValue(
        _pick(m, const <String>['assignmentMode', 'assignment_mode']),
      ),
      numberOfWorkers: _toInt(
        _pick(m, const <String>['numberOfWorkers', 'number_of_workers']),
      ),
      workerAcceptance:
          m['workerAcceptance'] == null && m['worker_acceptance'] == null
          ? null
          : CleaningWorkerAcceptanceModel.fromJson(
              _toMap(m['workerAcceptance'] ?? m['worker_acceptance']),
            ),
    );
  }

  bool get isMultiWorkerTeam =>
      (assignmentMode ?? '').toLowerCase() == 'open_count' ||
      (numberOfWorkers ?? 1) > 1;

  bool get isSearchingForWorkers {
    final statusNorm = (status ?? '').toLowerCase();
    if (statusNorm != CleaningBookingStatus.pending) return false;
    final acceptance = workerAcceptance;
    if (acceptance == null) return isMultiWorkerTeam;
    return acceptance.isFulfilled != true;
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
  final double? travelDistanceKm;
  final double? adminMargin;
  final double? cancellationFee;
  final double? totalPrice;
  final bool? isPricingFinal;
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
  final String? assignmentMode;
  final int? numberOfWorkers;
  final CleaningWorkerAcceptanceModel? workerAcceptance;
  final CleaningOrderWorkerModel? preferredWorker;
  final List<CleaningWorkerAssignmentModel>? workerAssignments;
  final List<CleaningRoomAssignmentModel>? roomAssignments;
  final CleaningMyAssignmentModel? myAssignment;

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
    this.travelDistanceKm,
    this.adminMargin,
    this.cancellationFee,
    this.totalPrice,
    this.isPricingFinal,
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
    this.assignmentMode,
    this.numberOfWorkers,
    this.workerAcceptance,
    this.preferredWorker,
    this.workerAssignments,
    this.roomAssignments,
    this.myAssignment,
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
      travelDistanceKm: _toDouble(
        _pick(m, const <String>['travelDistanceKm', 'travel_distance_km']),
      ),
      adminMargin: _toDouble(
        _pick(m, const <String>['adminMargin', 'admin_margin']),
      ),
      cancellationFee: _toDouble(
        _pick(m, const <String>['cancellationFee', 'cancellation_fee']),
      ),
      totalPrice: _toDouble(
        _pick(m, const <String>['totalPrice', 'total_price']),
      ),
      isPricingFinal: _toBool(
        _pick(m, const <String>['isPricingFinal', 'is_pricing_final']),
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
      assignmentMode: _toStringValue(
        _pick(m, const <String>['assignmentMode', 'assignment_mode']),
      ),
      numberOfWorkers: _toInt(
        _pick(m, const <String>['numberOfWorkers', 'number_of_workers']),
      ),
      workerAcceptance:
          m['workerAcceptance'] == null && m['worker_acceptance'] == null
          ? null
          : CleaningWorkerAcceptanceModel.fromJson(
              _toMap(m['workerAcceptance'] ?? m['worker_acceptance']),
            ),
      preferredWorker:
          m['preferredWorker'] == null && m['preferred_worker'] == null
          ? null
          : CleaningOrderWorkerModel.fromJson(
              _toMap(m['preferredWorker'] ?? m['preferred_worker']),
            ),
      workerAssignments: _toMapList(
        m['workerAssignments'] ?? m['worker_assignments'],
      ).map(CleaningWorkerAssignmentModel.fromJson).toList(growable: false),
      roomAssignments: _toMapList(
        m['roomAssignments'] ?? m['room_assignments'],
      ).map(CleaningRoomAssignmentModel.fromJson).toList(growable: false),
      myAssignment: m['myAssignment'] == null && m['my_assignment'] == null
          ? null
          : CleaningMyAssignmentModel.fromJson(
              _toMap(m['myAssignment'] ?? m['my_assignment']),
            ),
    );
  }

  bool get isMultiWorkerTeam =>
      (assignmentMode ?? '').toLowerCase() == 'open_count' ||
      (numberOfWorkers ?? 1) > 1;

  bool get isSearchingForWorkers {
    final statusNorm = (status ?? '').toLowerCase();
    if (statusNorm != CleaningBookingStatus.pending) return false;
    final acceptance = workerAcceptance;
    if (acceptance == null) return isMultiWorkerTeam;
    return acceptance.isFulfilled != true;
  }

  List<CleaningWorkerAssignmentModel> get acceptedWorkerAssignments {
    final assignments = workerAssignments ?? const [];
    return assignments
        .where((item) => (item.status ?? '').toLowerCase() == 'accepted')
        .toList(growable: false);
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
      travelDistanceKm: travelDistanceKm,
      adminMargin: adminMargin,
      cancellationFee: cancellationFee,
      totalPrice: totalPrice,
      isPricingFinal: isPricingFinal,
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
      assignmentMode: assignmentMode,
      numberOfWorkers: numberOfWorkers,
      workerAcceptance: workerAcceptance,
    );
  }
}

class CleaningMyAssignmentModel {
  final int? id;
  final int? workerId;
  final String? status;
  final String? acceptedAt;
  final int? roomCount;
  final double? roomsWeight;
  final double? serviceShareAmount;
  final double? travelFee;
  final double? adminMarginAmount;
  final double? workerAmount;
  final String? currency;
  final List<int>? roomIds;

  CleaningMyAssignmentModel({
    this.id,
    this.workerId,
    this.status,
    this.acceptedAt,
    this.roomCount,
    this.roomsWeight,
    this.serviceShareAmount,
    this.travelFee,
    this.adminMarginAmount,
    this.workerAmount,
    this.currency,
    this.roomIds,
  });

  factory CleaningMyAssignmentModel.fromJson(Map<String, dynamic> json) {
    final roomIdsRaw = json['roomIds'] ?? json['room_ids'];
    final roomIds = roomIdsRaw is List
        ? roomIdsRaw.map((item) => _toInt(item)).whereType<int>().toList()
        : null;

    return CleaningMyAssignmentModel(
      id: _toInt(_pick(json, const <String>['id'])),
      workerId: _toInt(_pick(json, const <String>['workerId', 'worker_id'])),
      status: _toStringValue(_pick(json, const <String>['status'])),
      acceptedAt: _toStringValue(
        _pick(json, const <String>['acceptedAt', 'accepted_at']),
      ),
      roomCount: _toInt(_pick(json, const <String>['roomCount', 'room_count'])),
      roomsWeight: _toDouble(
        _pick(json, const <String>['roomsWeight', 'rooms_weight']),
      ),
      serviceShareAmount: _toDouble(
        _pick(json, const <String>[
          'serviceShareAmount',
          'service_share_amount',
        ]),
      ),
      travelFee: _toDouble(
        _pick(json, const <String>['travelFee', 'travel_fee']),
      ),
      adminMarginAmount: _toDouble(
        _pick(json, const <String>['adminMarginAmount', 'admin_margin_amount']),
      ),
      workerAmount: _toDouble(
        _pick(json, const <String>['workerAmount', 'worker_amount']),
      ),
      currency: _toStringValue(_pick(json, const <String>['currency'])),
      roomIds: roomIds,
    );
  }
}

class CleaningWorkerAcceptanceModel {
  final int? required;
  final int? accepted;
  final int? remaining;
  final bool? isFulfilled;

  CleaningWorkerAcceptanceModel({
    this.required,
    this.accepted,
    this.remaining,
    this.isFulfilled,
  });

  factory CleaningWorkerAcceptanceModel.fromJson(Map<String, dynamic> json) {
    return CleaningWorkerAcceptanceModel(
      required: _toInt(_pick(json, const <String>['required'])),
      accepted: _toInt(_pick(json, const <String>['accepted'])),
      remaining: _toInt(_pick(json, const <String>['remaining'])),
      isFulfilled: _toBool(
        _pick(json, const <String>['isFulfilled', 'is_fulfilled']),
      ),
    );
  }
}

class CleaningWorkerAssignmentModel {
  final int? id;
  final int? workerId;
  final String? status;
  final String? acceptedAt;
  final int? roomCount;
  final double? roomsWeight;
  final double? serviceShareAmount;
  final double? travelFee;
  final double? adminMarginAmount;
  final double? workerAmount;
  final String? currency;
  final List<int>? roomIds;
  final CleaningOrderWorkerModel? worker;

  CleaningWorkerAssignmentModel({
    this.id,
    this.workerId,
    this.status,
    this.acceptedAt,
    this.roomCount,
    this.roomsWeight,
    this.serviceShareAmount,
    this.travelFee,
    this.adminMarginAmount,
    this.workerAmount,
    this.currency,
    this.roomIds,
    this.worker,
  });

  factory CleaningWorkerAssignmentModel.fromJson(Map<String, dynamic> json) {
    final roomIdsRaw = json['roomIds'] ?? json['room_ids'];
    final roomIds = roomIdsRaw is List
        ? roomIdsRaw.map((item) => _toInt(item)).whereType<int>().toList()
        : null;

    return CleaningWorkerAssignmentModel(
      id: _toInt(_pick(json, const <String>['id'])),
      workerId: _toInt(_pick(json, const <String>['workerId', 'worker_id'])),
      status: _toStringValue(_pick(json, const <String>['status'])),
      acceptedAt: _toStringValue(
        _pick(json, const <String>['acceptedAt', 'accepted_at']),
      ),
      roomCount: _toInt(_pick(json, const <String>['roomCount', 'room_count'])),
      roomsWeight: _toDouble(
        _pick(json, const <String>['roomsWeight', 'rooms_weight']),
      ),
      serviceShareAmount: _toDouble(
        _pick(json, const <String>[
          'serviceShareAmount',
          'service_share_amount',
        ]),
      ),
      travelFee: _toDouble(
        _pick(json, const <String>['travelFee', 'travel_fee']),
      ),
      adminMarginAmount: _toDouble(
        _pick(json, const <String>['adminMarginAmount', 'admin_margin_amount']),
      ),
      workerAmount: _toDouble(
        _pick(json, const <String>['workerAmount', 'worker_amount']),
      ),
      currency: _toStringValue(_pick(json, const <String>['currency'])),
      roomIds: roomIds,
      worker: json['worker'] == null
          ? null
          : CleaningOrderWorkerModel.fromJson(_toMap(json['worker'])),
    );
  }
}

class CleaningRoomAssignmentModel {
  final int? id;
  final String? roomKey;
  final String? roomType;
  final String? roomSize;
  final String? displayLabel;
  final double? weight;
  final int? plannedWorkerSlot;
  final int? plannedPreferredWorkerId;
  final int? assignedWorkerId;
  final String? assignmentSource;
  final CleaningOrderWorkerModel? assignedWorker;

  CleaningRoomAssignmentModel({
    this.id,
    this.roomKey,
    this.roomType,
    this.roomSize,
    this.displayLabel,
    this.weight,
    this.plannedWorkerSlot,
    this.plannedPreferredWorkerId,
    this.assignedWorkerId,
    this.assignmentSource,
    this.assignedWorker,
  });

  factory CleaningRoomAssignmentModel.fromJson(Map<String, dynamic> json) {
    return CleaningRoomAssignmentModel(
      id: _toInt(_pick(json, const <String>['id'])),
      roomKey: _toStringValue(
        _pick(json, const <String>['roomKey', 'room_key']),
      ),
      roomType: _toStringValue(
        _pick(json, const <String>['roomType', 'room_type']),
      ),
      roomSize: _toStringValue(
        _pick(json, const <String>['roomSize', 'room_size']),
      ),
      displayLabel: _toStringValue(
        _pick(json, const <String>['displayLabel', 'display_label']),
      ),
      weight: _toDouble(_pick(json, const <String>['weight'])),
      plannedWorkerSlot: _toInt(
        _pick(json, const <String>['plannedWorkerSlot', 'planned_worker_slot']),
      ),
      plannedPreferredWorkerId: _toInt(
        _pick(json, const <String>[
          'plannedPreferredWorkerId',
          'planned_preferred_worker_id',
        ]),
      ),
      assignedWorkerId: _toInt(
        _pick(json, const <String>['assignedWorkerId', 'assigned_worker_id']),
      ),
      assignmentSource: _toStringValue(
        _pick(json, const <String>['assignmentSource', 'assignment_source']),
      ),
      assignedWorker:
          json['assignedWorker'] == null && json['assigned_worker'] == null
          ? null
          : CleaningOrderWorkerModel.fromJson(
              _toMap(json['assignedWorker'] ?? json['assigned_worker']),
            ),
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
  final String? eventType;
  final int? guestCount;
  final String? venueType;
  final String? customService;
  final double? hours;
  final String? specialRequirement;
  final String? notes;

  CleaningPropertyDetailsModel({
    this.address,
    this.locationName,
    this.bedrooms,
    this.rooms,
    this.bathrooms,
    this.kitchens,
    this.livingRoomSize,
    this.eventType,
    this.guestCount,
    this.venueType,
    this.customService,
    this.hours,
    this.specialRequirement,
    this.notes,
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
      eventType: _toStringValue(
        _pick(json, const <String>['event_type', 'eventType']),
      ),
      guestCount: _toInt(
        _pick(json, const <String>['guest_count', 'guestCount']),
      ),
      venueType: _toStringValue(
        _pick(json, const <String>['venue_type', 'venueType']),
      ),
      customService: _toStringValue(
        _pick(json, const <String>['custom_service', 'customService']),
      ),
      hours: _toDouble(_pick(json, const <String>['hours'])),
      specialRequirement: _toStringValue(
        _pick(json, const <String>[
          'special_requirement',
          'specialRequirement',
        ]),
      ),
      notes: _toStringValue(_pick(json, const <String>['notes'])),
    );
  }
}
