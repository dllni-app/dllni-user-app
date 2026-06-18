double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
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

String? _asString(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is num || value is bool) return value.toString();
  return null;
}

bool? _asBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is String) {
    if (value.toLowerCase() == 'true') return true;
    if (value.toLowerCase() == 'false') return false;
  }
  return null;
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

List<Map<String, dynamic>> _asMapList(dynamic value) {
  if (value is List) {
    return value.map((item) => _asMap(item)).toList();
  }
  return <Map<String, dynamic>>[];
}

FetchDeliveryOrdersModel fetchDeliveryOrdersModelFromJson(dynamic json) =>
    FetchDeliveryOrdersModel.fromJson(_asMap(json));

FetchDeliveryOrderDetailsModel fetchDeliveryOrderDetailsModelFromJson(dynamic json) =>
    FetchDeliveryOrderDetailsModel.fromJson(_asMap(json));

class FetchDeliveryOrdersModel {
  List<DeliveryOrderModel> data;
  DeliveryOrdersMetaModel? meta;
  DeliveryOrdersLinksModel? links;

  FetchDeliveryOrdersModel({
    this.data = const <DeliveryOrderModel>[],
    this.meta,
    this.links,
  });

  factory FetchDeliveryOrdersModel.fromJson(Map<String, dynamic> json) {
    return FetchDeliveryOrdersModel(
      data: _asMapList(json['data']).map(DeliveryOrderModel.fromJson).toList(),
      meta: json['meta'] == null
          ? null
          : DeliveryOrdersMetaModel.fromJson(_asMap(json['meta'])),
      links: json['links'] == null
          ? null
          : DeliveryOrdersLinksModel.fromJson(_asMap(json['links'])),
    );
  }
}

class FetchDeliveryOrderDetailsModel {
  DeliveryOrderModel? data;

  FetchDeliveryOrderDetailsModel({this.data});

  factory FetchDeliveryOrderDetailsModel.fromJson(Map<String, dynamic> json) {
    return FetchDeliveryOrderDetailsModel(
      data: json['data'] == null
          ? null
          : DeliveryOrderModel.fromJson(_asMap(json['data'])),
    );
  }
}

class DeliveryOrdersMetaModel {
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? total;

  DeliveryOrdersMetaModel({this.currentPage, this.lastPage, this.perPage, this.total});

  factory DeliveryOrdersMetaModel.fromJson(Map<String, dynamic> json) {
    return DeliveryOrdersMetaModel(
      currentPage: _asInt(json['current_page']),
      lastPage: _asInt(json['last_page']),
      perPage: _asInt(json['per_page']),
      total: _asInt(json['total']),
    );
  }
}

class DeliveryOrdersLinksModel {
  String? next;

  DeliveryOrdersLinksModel({this.next});

  factory DeliveryOrdersLinksModel.fromJson(Map<String, dynamic> json) {
    return DeliveryOrdersLinksModel(next: _asString(json['next']));
  }
}

class DeliveryOrderModel {
  int? id;
  String? orderNumber;
  int? companyId;
  DeliveryCompanyModel? company;
  int? driverId;
  DeliveryDriverModel? driver;
  String? status;
  String? statusLabelAr;
  String? customerName;
  String? customerPhone;
  String? customerNotes;
  String? pickupAddress;
  double? pickupLatitude;
  double? pickupLongitude;
  String? dropoffAddress;
  double? dropoffLatitude;
  double? dropoffLongitude;
  double? distanceKm;
  double? deliveryFee;
  String? currency;
  String? acceptedAt;
  String? startedAt;
  String? pickedUpAt;
  String? deliveredAt;
  String? completedAt;
  String? stoppedAt;
  String? cancelledAt;
  String? stopReason;
  String? cancelReason;
  List<DeliveryTimelineStageModel> timeline;
  DeliveryTrackingModel? tracking;
  List<DeliveryEventModel> events;
  int? createdByUserId;
  String? createdAt;
  String? updatedAt;

  DeliveryOrderModel({
    this.id,
    this.orderNumber,
    this.companyId,
    this.company,
    this.driverId,
    this.driver,
    this.status,
    this.statusLabelAr,
    this.customerName,
    this.customerPhone,
    this.customerNotes,
    this.pickupAddress,
    this.pickupLatitude,
    this.pickupLongitude,
    this.dropoffAddress,
    this.dropoffLatitude,
    this.dropoffLongitude,
    this.distanceKm,
    this.deliveryFee,
    this.currency,
    this.acceptedAt,
    this.startedAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.completedAt,
    this.stoppedAt,
    this.cancelledAt,
    this.stopReason,
    this.cancelReason,
    this.timeline = const <DeliveryTimelineStageModel>[],
    this.tracking,
    this.events = const <DeliveryEventModel>[],
    this.createdByUserId,
    this.createdAt,
    this.updatedAt,
  });

  factory DeliveryOrderModel.fromJson(Map<String, dynamic> json) {
    return DeliveryOrderModel(
      id: _asInt(json['id']),
      orderNumber: _asString(json['orderNumber']),
      companyId: _asInt(json['companyId']),
      company: json['company'] == null
          ? null
          : DeliveryCompanyModel.fromJson(_asMap(json['company'])),
      driverId: _asInt(json['driverId']),
      driver: json['driver'] == null
          ? null
          : DeliveryDriverModel.fromJson(_asMap(json['driver'])),
      status: _asString(json['status']),
      statusLabelAr: _asString(json['statusLabelAr']),
      customerName: _asString(json['customerName']),
      customerPhone: _asString(json['customerPhone']),
      customerNotes: _asString(json['customerNotes']),
      pickupAddress: _asString(json['pickupAddress']),
      pickupLatitude: _asDouble(json['pickupLatitude']),
      pickupLongitude: _asDouble(json['pickupLongitude']),
      dropoffAddress: _asString(json['dropoffAddress']),
      dropoffLatitude: _asDouble(json['dropoffLatitude']),
      dropoffLongitude: _asDouble(json['dropoffLongitude']),
      distanceKm: _asDouble(json['distanceKm']),
      deliveryFee: _asDouble(json['deliveryFee']),
      currency: _asString(json['currency']),
      acceptedAt: _asString(json['acceptedAt']),
      startedAt: _asString(json['startedAt']),
      pickedUpAt: _asString(json['pickedUpAt']),
      deliveredAt: _asString(json['deliveredAt']),
      completedAt: _asString(json['completedAt']),
      stoppedAt: _asString(json['stoppedAt']),
      cancelledAt: _asString(json['cancelledAt']),
      stopReason: _asString(json['stopReason']),
      cancelReason: _asString(json['cancelReason']),
      timeline: _asMapList(json['timeline'])
          .map(DeliveryTimelineStageModel.fromJson)
          .toList(),
      tracking: json['tracking'] == null
          ? null
          : DeliveryTrackingModel.fromJsonMap(_asMap(json['tracking'])),
      events: _asMapList(json['events']).map(DeliveryEventModel.fromJson).toList(),
      createdByUserId: _asInt(json['createdByUserId']),
      createdAt: _asString(json['createdAt']),
      updatedAt: _asString(json['updatedAt']),
    );
  }

  bool get isTerminal {
    const terminal = {'completed', 'stopped', 'cancelled'};
    final s = (status ?? tracking?.currentStatus ?? '').toLowerCase();
    return terminal.contains(s);
  }

  String get displayStatusLabel =>
      tracking?.currentStatusLabelAr ?? statusLabelAr ?? status ?? '—';

  String get etaLabel {
    final eta = tracking?.eta;
    if (eta != null) {
      if (eta.text.isNotEmpty) return eta.text;
      if ((eta.minutes ?? 0) > 0) return '${eta.minutes} دقيقة';
    }
    return '';
  }
}

class DeliveryCompanyModel {
  int? id;
  String? name;
  String? phone;
  String? email;

  DeliveryCompanyModel({this.id, this.name, this.phone, this.email});

  factory DeliveryCompanyModel.fromJson(Map<String, dynamic> json) {
    return DeliveryCompanyModel(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      phone: _asString(json['phone']),
      email: _asString(json['email']),
    );
  }
}

class DeliveryDriverModel {
  int? id;
  int? userId;
  int? companyId;
  String? firstName;
  String? displayName;
  String? phone;
  String? vehicleType;
  String? plateNumber;
  String? availabilityStatus;
  bool? isActive;
  bool? isSuspended;
  double? trustScore;
  int? openDisputesCount;
  String? lastSeenAt;
  DeliveryLocationModel? latestLocation;
  String? createdAt;

  DeliveryDriverModel({
    this.id,
    this.userId,
    this.companyId,
    this.firstName,
    this.displayName,
    this.phone,
    this.vehicleType,
    this.plateNumber,
    this.availabilityStatus,
    this.isActive,
    this.isSuspended,
    this.trustScore,
    this.openDisputesCount,
    this.lastSeenAt,
    this.latestLocation,
    this.createdAt,
  });

  factory DeliveryDriverModel.fromJson(Map<String, dynamic> json) {
    return DeliveryDriverModel(
      id: _asInt(json['id']),
      userId: _asInt(json['userId']),
      companyId: _asInt(json['companyId']),
      firstName: _asString(json['firstName']),
      displayName: _asString(json['displayName']),
      phone: _asString(json['phone']),
      vehicleType: _asString(json['vehicleType']),
      plateNumber: _asString(json['plateNumber']),
      availabilityStatus: _asString(json['availabilityStatus']),
      isActive: _asBool(json['isActive']),
      isSuspended: _asBool(json['isSuspended']),
      trustScore: _asDouble(json['trustScore']),
      openDisputesCount: _asInt(json['openDisputesCount']),
      lastSeenAt: _asString(json['lastSeenAt']),
      latestLocation: json['latestLocation'] == null
          ? null
          : DeliveryLocationModel.fromJson(_asMap(json['latestLocation'])),
      createdAt: _asString(json['createdAt']),
    );
  }

  String get name => displayName ?? firstName ?? 'المندوب';
}

class DeliveryLocationModel {
  int? id;
  int? driverId;
  double? latitude;
  double? longitude;
  double? accuracy;
  double? speed;
  double? heading;
  String? recordedAt;

  DeliveryLocationModel({
    this.id,
    this.driverId,
    this.latitude,
    this.longitude,
    this.accuracy,
    this.speed,
    this.heading,
    this.recordedAt,
  });

  factory DeliveryLocationModel.fromJson(Map<String, dynamic> json) {
    return DeliveryLocationModel(
      id: _asInt(json['id']),
      driverId: _asInt(json['driverId']),
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
      accuracy: _asDouble(json['accuracy']),
      speed: _asDouble(json['speed']),
      heading: _asDouble(json['heading']),
      recordedAt: _asString(json['recordedAt']),
    );
  }
}

class DeliveryTrackingModel {
  String? currentStatus;
  String? currentStatusLabelAr;
  DeliveryEtaModel? eta;
  DeliveryMapModel? map;
  List<DeliveryTimelineStageModel> timeline;
  List<DeliveryTimelineStageModel> stages;
  DeliveryDriverModel? driver;
  DeliveryPointModel? pickup;
  DeliveryPointModel? dropoff;
  List<DeliveryPointModel> route;

  DeliveryTrackingModel({
    this.currentStatus,
    this.currentStatusLabelAr,
    this.eta,
    this.map,
    this.timeline = const <DeliveryTimelineStageModel>[],
    this.stages = const <DeliveryTimelineStageModel>[],
    this.driver,
    this.pickup,
    this.dropoff,
    this.route = const <DeliveryPointModel>[],
  });

  factory DeliveryTrackingModel.fromJsonMap(Map<String, dynamic> json) {
    final timeline = _asMapList(json['timeline'])
        .map(DeliveryTimelineStageModel.fromJson)
        .toList();
    final stages = _asMapList(json['stages'])
        .map(DeliveryTimelineStageModel.fromJson)
        .toList();
    return DeliveryTrackingModel(
      currentStatus: _asString(json['currentStatus']),
      currentStatusLabelAr: _asString(json['currentStatusLabelAr']),
      eta: json['eta'] == null ? null : DeliveryEtaModel.fromJson(_asMap(json['eta'])),
      map: json['map'] == null ? null : DeliveryMapModel.fromJson(_asMap(json['map'])),
      timeline: timeline,
      stages: stages.isNotEmpty ? stages : timeline,
      driver: json['driver'] == null
          ? null
          : DeliveryDriverModel.fromJson(_asMap(json['driver'])),
      pickup: json['pickup'] == null
          ? null
          : DeliveryPointModel.fromJson(_asMap(json['pickup'])),
      dropoff: json['dropoff'] == null
          ? null
          : DeliveryPointModel.fromJson(_asMap(json['dropoff'])),
      route: _asMapList(json['route']).map(DeliveryPointModel.fromJson).toList(),
    );
  }
}

class DeliveryEtaModel {
  int? minutes;
  String text;
  double? referenceDistanceKm;
  String? updatedAt;

  DeliveryEtaModel({
    this.minutes,
    this.text = '',
    this.referenceDistanceKm,
    this.updatedAt,
  });

  factory DeliveryEtaModel.fromJson(Map<String, dynamic> json) {
    return DeliveryEtaModel(
      minutes: _asInt(json['minutes']),
      text: _asString(json['text']) ?? '',
      referenceDistanceKm: _asDouble(json['referenceDistanceKm']),
      updatedAt: _asString(json['updatedAt']),
    );
  }
}

class DeliveryMapModel {
  bool enabled;
  double? centerLatitude;
  double? centerLongitude;
  double zoom;
  List<DeliveryMapMarkerModel> markers;
  List<DeliveryMapRoutePointModel> route;
  double? routeDistanceKm;

  DeliveryMapModel({
    this.enabled = false,
    this.centerLatitude,
    this.centerLongitude,
    this.zoom = 13,
    this.markers = const <DeliveryMapMarkerModel>[],
    this.route = const <DeliveryMapRoutePointModel>[],
    this.routeDistanceKm,
  });

  factory DeliveryMapModel.fromJson(Map<String, dynamic> json) {
    return DeliveryMapModel(
      enabled: _asBool(json['enabled']) ?? false,
      centerLatitude: _asDouble(json['centerLatitude']),
      centerLongitude: _asDouble(json['centerLongitude']),
      zoom: _asDouble(json['zoom']) ?? 13,
      markers: _asMapList(json['markers'])
          .map(DeliveryMapMarkerModel.fromJson)
          .toList(),
      route: _asMapList(json['route'])
          .map(DeliveryMapRoutePointModel.fromJson)
          .toList(),
      routeDistanceKm: _asDouble(json['routeDistanceKm']),
    );
  }
}

class DeliveryMapMarkerModel {
  String? kind;
  double? latitude;
  double? longitude;
  String? address;
  double? accuracy;
  double? speed;
  double? heading;
  String? recordedAt;

  DeliveryMapMarkerModel({
    this.kind,
    this.latitude,
    this.longitude,
    this.address,
    this.accuracy,
    this.speed,
    this.heading,
    this.recordedAt,
  });

  factory DeliveryMapMarkerModel.fromJson(Map<String, dynamic> json) {
    return DeliveryMapMarkerModel(
      kind: _asString(json['kind']),
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
      address: _asString(json['address']),
      accuracy: _asDouble(json['accuracy']),
      speed: _asDouble(json['speed']),
      heading: _asDouble(json['heading']),
      recordedAt: _asString(json['recordedAt']),
    );
  }
}

class DeliveryMapRoutePointModel {
  double? latitude;
  double? longitude;

  DeliveryMapRoutePointModel({this.latitude, this.longitude});

  factory DeliveryMapRoutePointModel.fromJson(Map<String, dynamic> json) {
    return DeliveryMapRoutePointModel(
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
    );
  }
}

class DeliveryPointModel {
  String? kind;
  double? latitude;
  double? longitude;
  String? address;

  DeliveryPointModel({this.kind, this.latitude, this.longitude, this.address});

  factory DeliveryPointModel.fromJson(Map<String, dynamic> json) {
    return DeliveryPointModel(
      kind: _asString(json['kind']),
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
      address: _asString(json['address']),
    );
  }
}

class DeliveryTimelineStageModel {
  String? key;
  String? timestamp;
  bool completed;
  bool active;

  DeliveryTimelineStageModel({
    this.key,
    this.timestamp,
    this.completed = false,
    this.active = false,
  });

  factory DeliveryTimelineStageModel.fromJson(Map<String, dynamic> json) {
    return DeliveryTimelineStageModel(
      key: _asString(json['key']),
      timestamp: _asString(json['timestamp']),
      completed: _asBool(json['completed']) ?? false,
      active: _asBool(json['active']) ?? false,
    );
  }

  static const stageLabels = <String, String>{
    'created': 'تم إنشاء الطلب',
    'searching_driver': 'البحث عن مندوب',
    'driver_en_route': 'المندوب في الطريق',
    'arrived_pickup': 'وصل لنقطة الاستلام',
    'handover_complete': 'تم الاستلام',
    'delivered': 'تم التسليم',
    'completed': 'مكتمل',
    'stopped': 'متوقف',
    'cancelled': 'ملغى',
  };

  String get label => stageLabels[key ?? ''] ?? key ?? '—';
}

class DeliveryEventModel {
  int? id;
  String? fromStatus;
  String? toStatus;
  String? note;
  Map<String, dynamic>? payload;
  String? createdAt;

  DeliveryEventModel({
    this.id,
    this.fromStatus,
    this.toStatus,
    this.note,
    this.payload,
    this.createdAt,
  });

  factory DeliveryEventModel.fromJson(Map<String, dynamic> json) {
    return DeliveryEventModel(
      id: _asInt(json['id']),
      fromStatus: _asString(json['fromStatus']),
      toStatus: _asString(json['toStatus']),
      note: _asString(json['note']),
      payload: json['payload'] is Map
          ? Map<String, dynamic>.from(json['payload'] as Map)
          : null,
      createdAt: _asString(json['createdAt']),
    );
  }
}
