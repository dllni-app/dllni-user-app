import '../../../delivery/data/models/delivery_order_models.dart';

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
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.toLowerCase().trim();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
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

List<int> _asIntList(dynamic value) {
  if (value is List) {
    return value.map((e) => _asInt(e)).whereType<int>().toList();
  }
  return <int>[];
}

FetchOrdersModel fetchOrdersModelFromJson(dynamic json) =>
    FetchOrdersModel.fromJson(_asMap(json));

FetchOrderDetailsModel fetchOrderDetailsModelFromJson(dynamic json) =>
    FetchOrderDetailsModel.fromJson(_asMap(json));

OrdersActionResultModel ordersActionResultModelFromJson(dynamic json) =>
    OrdersActionResultModel.fromJson(_asMap(json));

PlaceRestaurantOrderModel placeRestaurantOrderModelFromJson(dynamic json) =>
    PlaceRestaurantOrderModel.fromJson(_asMap(json));

CouponCheckModel couponCheckModelFromJson(dynamic json) =>
    CouponCheckModel.fromJson(_asMap(json));

FetchRestaurantCartModel fetchRestaurantCartModelFromJson(dynamic json) =>
    FetchRestaurantCartModel.fromJson(_asMap(json));

class FetchOrdersModel {
  List<OrderResourceModel> data;
  OrdersMetaModel? meta;
  OrdersLinksModel? links;

  FetchOrdersModel({required this.data, this.meta, this.links});

  factory FetchOrdersModel.fromJson(Map<String, dynamic> json) {
    return FetchOrdersModel(
      data: _asMapList(json['data']).map(OrderResourceModel.fromJson).toList(),
      meta: json['meta'] == null ? null : OrdersMetaModel.fromJson(_asMap(json['meta'])),
      links: json['links'] == null ? null : OrdersLinksModel.fromJson(_asMap(json['links'])),
    );
  }
}

class FetchOrderDetailsModel {
  OrderResourceModel? data;

  FetchOrderDetailsModel({this.data});

  factory FetchOrderDetailsModel.fromJson(Map<String, dynamic> json) {
    return FetchOrderDetailsModel(
      data: json['data'] == null ? null : OrderResourceModel.fromJson(_asMap(json['data'])),
    );
  }
}

class OrdersMetaModel {
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? total;

  OrdersMetaModel({this.currentPage, this.lastPage, this.perPage, this.total});

  factory OrdersMetaModel.fromJson(Map<String, dynamic> json) {
    return OrdersMetaModel(
      currentPage: _asInt(json['current_page']),
      lastPage: _asInt(json['last_page']),
      perPage: _asInt(json['per_page']),
      total: _asInt(json['total']),
    );
  }
}

class OrdersLinksModel {
  String? first;
  String? last;
  String? prev;
  String? next;

  OrdersLinksModel({this.first, this.last, this.prev, this.next});

  factory OrdersLinksModel.fromJson(Map<String, dynamic> json) {
    return OrdersLinksModel(
      first: _asString(json['first']),
      last: _asString(json['last']),
      prev: _asString(json['prev']),
      next: _asString(json['next']),
    );
  }
}

class DeliverySummaryModel {
  final bool enabled;
  final String? status;
  final String? statusLabelAr;
  final String? currentStage;
  final bool isTerminal;
  final String? pickupMode;
  final String? readyForPickupAt;
  final String? pickedUpAt;
  final String? completedAt;
  final String? cancelledAt;
  final String? cancellationReason;
  final List<DeliveryTimelineStageModel> timeline;

  DeliverySummaryModel({
    this.enabled = false,
    this.status,
    this.statusLabelAr,
    this.currentStage,
    this.isTerminal = false,
    this.pickupMode,
    this.readyForPickupAt,
    this.pickedUpAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.timeline = const <DeliveryTimelineStageModel>[],
  });

  factory DeliverySummaryModel.fromJson(Map<String, dynamic> json) {
    return DeliverySummaryModel(
      enabled: _asBool(json['enabled']) ?? false,
      status: _asString(json['status']),
      statusLabelAr: _asString(json['statusLabelAr']) ?? _asString(json['status_label_ar']),
      currentStage: _asString(json['currentStage']) ?? _asString(json['current_stage']),
      isTerminal: _asBool(json['isTerminal']) ?? _asBool(json['is_terminal']) ?? false,
      pickupMode: _asString(json['pickupMode']) ?? _asString(json['pickup_mode']),
      readyForPickupAt: _asString(json['readyForPickupAt']) ?? _asString(json['ready_for_pickup_at']),
      pickedUpAt: _asString(json['pickedUpAt']) ?? _asString(json['picked_up_at']),
      completedAt: _asString(json['completedAt']) ?? _asString(json['completed_at']),
      cancelledAt: _asString(json['cancelledAt']) ?? _asString(json['cancelled_at']),
      cancellationReason: _asString(json['cancellationReason']) ?? _asString(json['cancellation_reason']),
      timeline: _asMapList(json['timeline']).map(DeliveryTimelineStageModel.fromJson).toList(),
    );
  }
}

class OrderResourceModel {
  int? id;
  int? deliveryOrderId;
  DeliverySummaryModel? deliverySummary;
  String? section;
  String? orderNumber;
  String? status;
  String? statusLabel;
  OrderMerchantModel? merchant;
  OrderFulfillmentModel? fulfillment;
  OrderAmountsModel? amounts;
  List<OrderItemModel> items;
  List<dynamic> timeline;
  OrderActionsModel? actions;
  String? createdAt;
  String? updatedAt;

  OrderResourceModel({
    this.id,
    this.deliveryOrderId,
    this.deliverySummary,
    this.section,
    this.orderNumber,
    this.status,
    this.statusLabel,
    this.merchant,
    this.fulfillment,
    this.amounts,
    this.items = const <OrderItemModel>[],
    this.timeline = const <dynamic>[],
    this.actions,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderResourceModel.fromJson(Map<String, dynamic> json) {
    final deliveryMap = _asMap(json['delivery']);
    final deliverySummaryJson = _asMap(json['deliverySummary']).isNotEmpty
        ? _asMap(json['deliverySummary'])
        : _asMap(json['delivery_summary']);

    return OrderResourceModel(
      id: _asInt(json['id']),
      deliveryOrderId: _asInt(json['deliveryOrderId']) ?? _asInt(json['delivery_order_id']) ?? _asInt(deliveryMap['id']),
      deliverySummary: deliverySummaryJson.isEmpty ? null : DeliverySummaryModel.fromJson(deliverySummaryJson),
      section: _asString(json['section']),
      orderNumber: _asString(json['orderNumber']),
      status: _asString(json['status']),
      statusLabel: _asString(json['statusLabel']),
      merchant: json['merchant'] == null ? null : OrderMerchantModel.fromJson(_asMap(json['merchant'])),
      fulfillment: json['fulfillment'] == null ? null : OrderFulfillmentModel.fromJson(_asMap(json['fulfillment'])),
      amounts: json['amounts'] == null ? null : OrderAmountsModel.fromJson(_asMap(json['amounts'])),
      items: _asMapList(json['items']).map(OrderItemModel.fromJson).toList(),
      timeline: json['timeline'] is List ? json['timeline'] as List : <dynamic>[],
      actions: json['actions'] == null ? null : OrderActionsModel.fromJson(_asMap(json['actions'])),
      createdAt: _asString(json['createdAt']),
      updatedAt: _asString(json['updatedAt']),
    );
  }

  bool get hasDeliveryTracking => deliveryOrderId != null;

  String? get deliveryStatusLabel {
    final label = deliverySummary?.statusLabelAr;
    if (label != null && label.trim().isNotEmpty) return label;
    return null;
  }
}

class OrderMerchantModel {
  int? id;
  String? name;
  String? address;
  String? city;
  String? district;
  String? locationDetails;
  double? latitude;
  double? longitude;

  OrderMerchantModel({this.id, this.name, this.address, this.city, this.district, this.locationDetails, this.latitude, this.longitude});

  factory OrderMerchantModel.fromJson(Map<String, dynamic> json) {
    return OrderMerchantModel(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      address: _asString(json['address']),
      city: _asString(json['city']),
      district: _asString(json['district']),
      locationDetails: _asString(json['locationDetails']) ?? _asString(json['location_details']),
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
    );
  }
}

class OrderFulfillmentModel {
  String? type;
  String? receiveMode;
  String? scheduledAt;

  OrderFulfillmentModel({this.type, this.receiveMode, this.scheduledAt});

  factory OrderFulfillmentModel.fromJson(Map<String, dynamic> json) {
    return OrderFulfillmentModel(
      type: _asString(json['type']),
      receiveMode: _asString(json['receiveMode']),
      scheduledAt: _asString(json['scheduledAt']),
    );
  }
}

class OrderAmountsModel {
  double subtotal;
  double discount;
  double serviceFee;
  double tax;
  double total;

  OrderAmountsModel({this.subtotal = 0, this.discount = 0, this.serviceFee = 0, this.tax = 0, this.total = 0});

  factory OrderAmountsModel.fromJson(Map<String, dynamic> json) {
    return OrderAmountsModel(
      subtotal: _asDouble(json['subtotal']) ?? 0,
      discount: _asDouble(json['discount']) ?? 0,
      serviceFee: _asDouble(json['serviceFee']) ?? 0,
      tax: _asDouble(json['tax']) ?? 0,
      total: _asDouble(json['total']) ?? 0,
    );
  }
}

class OrderItemModel {
  int? id;
  int? productId;
  String? name;
  int quantity;
  double unitPrice;
  double totalPrice;
  String? note;

  OrderItemModel({this.id, this.productId, this.name, this.quantity = 0, this.unitPrice = 0, this.totalPrice = 0, this.note});

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: _asInt(json['id']),
      productId: _asInt(json['productId']),
      name: _asString(json['name']),
      quantity: _asInt(json['quantity']) ?? 0,
      unitPrice: _asDouble(json['unitPrice']) ?? 0,
      totalPrice: _asDouble(json['totalPrice']) ?? 0,
      note: _asString(json['note']),
    );
  }
}

class OrderActionsModel {
  bool canCancel;
  bool canReorder;
  bool canReschedule;

  OrderActionsModel({this.canCancel = false, this.canReorder = false, this.canReschedule = false});

  factory OrderActionsModel.fromJson(Map<String, dynamic> json) {
    return OrderActionsModel(
      canCancel: _asBool(json['canCancel']) ?? false,
      canReorder: _asBool(json['canReorder']) ?? false,
      canReschedule: _asBool(json['canReschedule']) ?? false,
    );
  }
}

class OrdersActionResultModel {
  String? message;

  OrdersActionResultModel({this.message});

  factory OrdersActionResultModel.fromJson(Map<String, dynamic> json) {
    return OrdersActionResultModel(message: _asString(json['message']));
  }
}

class PlaceRestaurantOrderModel {
  String? message;
  OrderResourceModel? data;

  PlaceRestaurantOrderModel({this.message, this.data});

  factory PlaceRestaurantOrderModel.fromJson(Map<String, dynamic> json) {
    return PlaceRestaurantOrderModel(
      message: _asString(json['message']),
      data: json['data'] == null ? null : OrderResourceModel.fromJson(_asMap(json['data'])),
    );
  }
}

class CouponCheckModel {
  CouponCheckDataModel? data;

  CouponCheckModel({this.data});

  factory CouponCheckModel.fromJson(Map<String, dynamic> json) {
    return CouponCheckModel(
      data: json['data'] == null ? null : CouponCheckDataModel.fromJson(_asMap(json['data'])),
    );
  }
}

class CouponCheckDataModel {
  String? section;
  String? couponCode;
  bool isAvailable;
  String? reason;
  CouponCheckAmountsModel? amounts;
  CouponMetaModel? coupon;

  CouponCheckDataModel({this.section, this.couponCode, this.isAvailable = false, this.reason, this.amounts, this.coupon});

  factory CouponCheckDataModel.fromJson(Map<String, dynamic> json) {
    return CouponCheckDataModel(
      section: _asString(json['section']),
      couponCode: _asString(json['couponCode']),
      isAvailable: _asBool(json['isAvailable']) ?? false,
      reason: _asString(json['reason']),
      amounts: json['amounts'] == null ? null : CouponCheckAmountsModel.fromJson(_asMap(json['amounts'])),
      coupon: json['coupon'] == null ? null : CouponMetaModel.fromJson(_asMap(json['coupon'])),
    );
  }
}

class CouponCheckAmountsModel {
  double subtotal;
  double discount;
  double total;

  CouponCheckAmountsModel({this.subtotal = 0, this.discount = 0, this.total = 0});

  factory CouponCheckAmountsModel.fromJson(Map<String, dynamic> json) {
    return CouponCheckAmountsModel(
      subtotal: _asDouble(json['subtotal']) ?? 0,
      discount: _asDouble(json['discount']) ?? 0,
      total: _asDouble(json['total']) ?? 0,
    );
  }
}

class CouponMetaModel {
  String? type;
  double? value;
  double? percent;
  double? minOrderAmount;
  double? maxDiscountAmount;

  CouponMetaModel({this.type, this.value, this.percent, this.minOrderAmount, this.maxDiscountAmount});

  factory CouponMetaModel.fromJson(Map<String, dynamic> json) {
    return CouponMetaModel(
      type: _asString(json['type']),
      value: _asDouble(json['value']),
      percent: _asDouble(json['percent']),
      minOrderAmount: _asDouble(json['minOrderAmount']),
      maxDiscountAmount: _asDouble(json['maxDiscountAmount']),
    );
  }
}

class FetchRestaurantCartModel {
  RestaurantCartDataModel? data;

  FetchRestaurantCartModel({this.data});

  factory FetchRestaurantCartModel.fromJson(Map<String, dynamic> json) {
    return FetchRestaurantCartModel(
      data: json['data'] == null ? null : RestaurantCartDataModel.fromJson(_asMap(json['data'])),
    );
  }
}

class RestaurantCartDataModel {
  int? id;
  OrderMerchantModel? merchant;
  List<RestaurantCartItemModel> items;
  RestaurantCartAmountsModel? amounts;

  RestaurantCartDataModel({this.id, this.merchant, this.items = const <RestaurantCartItemModel>[], this.amounts});

  factory RestaurantCartDataModel.fromJson(Map<String, dynamic> json) {
    return RestaurantCartDataModel(
      id: _asInt(json['id']),
      merchant: json['merchant'] == null ? null : OrderMerchantModel.fromJson(_asMap(json['merchant'])),
      items: _asMapList(json['items']).map(RestaurantCartItemModel.fromJson).toList(),
      amounts: json['amounts'] == null ? null : RestaurantCartAmountsModel.fromJson(_asMap(json['amounts'])),
    );
  }
}

class RestaurantCartAmountsModel {
  double subtotal;
  double discount;
  double discountPercent;
  double total;

  RestaurantCartAmountsModel({
    this.subtotal = 0,
    this.discount = 0,
    this.discountPercent = 0,
    this.total = 0,
  });

  factory RestaurantCartAmountsModel.fromJson(Map<String, dynamic> json) {
    final subtotal = _asDouble(json['subtotal']) ?? 0;
    final total = _asDouble(json['total']) ?? 0;
    final discount = _asDouble(json['discount']) ?? (subtotal > total ? subtotal - total : 0);
    return RestaurantCartAmountsModel(
      subtotal: subtotal,
      discount: discount,
      discountPercent: _asDouble(json['discountPercent']) ?? (subtotal > 0 ? (discount / subtotal) * 100 : 0),
      total: total,
    );
  }
}

class RestaurantCartItemModel {
  int? id;
  int? productId;
  String? name;
  int quantity;
  double unitPrice;
  double totalPrice;
  double? originalUnitPrice;
  double? originalTotalPrice;
  double? productPrice;
  double? originalProductPrice;
  bool hasDiscount;
  List<int> modifierIds;
  int? substituteProductId;
  String? note;
  String? imageUrl;

  RestaurantCartItemModel({
    this.id,
    this.productId,
    this.name,
    this.quantity = 0,
    this.unitPrice = 0,
    this.totalPrice = 0,
    this.originalUnitPrice,
    this.originalTotalPrice,
    this.productPrice,
    this.originalProductPrice,
    this.hasDiscount = false,
    this.modifierIds = const <int>[],
    this.substituteProductId,
    this.note,
    this.imageUrl,
  });

  factory RestaurantCartItemModel.fromJson(Map<String, dynamic> json) {
    final unitPrice = _asDouble(json['unitPrice']) ?? 0;
    final totalPrice = _asDouble(json['totalPrice']) ?? 0;
    final originalUnitPrice = _asDouble(json['originalUnitPrice']);
    final originalTotalPrice = _asDouble(json['originalTotalPrice']);
    return RestaurantCartItemModel(
      id: _asInt(json['id']),
      productId: _asInt(json['productId']),
      name: _asString(json['name']),
      quantity: _asInt(json['quantity']) ?? 0,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
      originalUnitPrice: originalUnitPrice,
      originalTotalPrice: originalTotalPrice,
      productPrice: _asDouble(json['productPrice']),
      originalProductPrice: _asDouble(json['originalProductPrice']),
      hasDiscount: _asBool(json['hasDiscount']) ??
          (originalTotalPrice != null && originalTotalPrice > totalPrice) ||
          (originalUnitPrice != null && originalUnitPrice > unitPrice),
      modifierIds: _asIntList(json['modifierIds']),
      substituteProductId: _asInt(json['substituteProductId']),
      note: _asString(json['note']),
      imageUrl: _asString(json['imageUrl']),
    );
  }
}

FetchRestaurantOrderTrackingModel fetchRestaurantOrderTrackingModelFromJson(dynamic json) =>
    FetchRestaurantOrderTrackingModel.fromJson(_asMap(json));

class FetchRestaurantOrderTrackingModel {
  RestaurantOrderTrackingDataModel? data;

  FetchRestaurantOrderTrackingModel({this.data});

  factory FetchRestaurantOrderTrackingModel.fromJson(Map<String, dynamic> json) {
    return FetchRestaurantOrderTrackingModel(
      data: json['data'] == null ? null : RestaurantOrderTrackingDataModel.fromJson(_asMap(json['data'])),
    );
  }
}

class RestaurantOrderTrackingDataModel {
  RestaurantOrderTrackingEtaModel? eta;
  RestaurantOrderTrackingMapModel? map;
  List<RestaurantOrderTrackingTimelineItemModel> timeline;
  RestaurantOrderTrackingMerchantModel? merchant;
  OrderActionsModel? actions;

  RestaurantOrderTrackingDataModel({this.eta, this.map, this.timeline = const <RestaurantOrderTrackingTimelineItemModel>[], this.merchant, this.actions});

  factory RestaurantOrderTrackingDataModel.fromJson(Map<String, dynamic> json) {
    return RestaurantOrderTrackingDataModel(
      eta: json['eta'] == null ? null : RestaurantOrderTrackingEtaModel.fromJson(_asMap(json['eta'])),
      map: json['map'] == null ? null : RestaurantOrderTrackingMapModel.fromJson(_asMap(json['map'])),
      timeline: _asMapList(json['timeline']).map(RestaurantOrderTrackingTimelineItemModel.fromJson).toList(),
      merchant: json['merchant'] == null ? null : RestaurantOrderTrackingMerchantModel.fromJson(_asMap(json['merchant'])),
      actions: json['actions'] == null ? null : OrderActionsModel.fromJson(_asMap(json['actions'])),
    );
  }

  String? get latestToStatus {
    for (var i = timeline.length - 1; i >= 0; i--) {
      final s = timeline[i].toStatus;
      if (s != null && s.isNotEmpty) return s;
    }
    return null;
  }
}

class RestaurantOrderTrackingEtaModel {
  int minutes;
  String text;

  RestaurantOrderTrackingEtaModel({this.minutes = 0, this.text = ''});

  factory RestaurantOrderTrackingEtaModel.fromJson(Map<String, dynamic> json) {
    return RestaurantOrderTrackingEtaModel(
      minutes: _asInt(json['minutes']) ?? 0,
      text: _asString(json['text']) ?? '',
    );
  }
}

class RestaurantOrderTrackingMapModel {
  bool enabled;
  double? lat;
  double? lng;

  RestaurantOrderTrackingMapModel({this.enabled = false, this.lat, this.lng});

  factory RestaurantOrderTrackingMapModel.fromJson(Map<String, dynamic> json) {
    return RestaurantOrderTrackingMapModel(
      enabled: _asBool(json['enabled']) ?? false,
      lat: _asDouble(json['lat']),
      lng: _asDouble(json['lng']),
    );
  }

  bool get hasCoordinates => lat != null && lng != null;
}

class RestaurantOrderTrackingTimelineItemModel {
  String? fromStatus;
  String? toStatus;
  String? note;
  String? changedAt;

  RestaurantOrderTrackingTimelineItemModel({this.fromStatus, this.toStatus, this.note, this.changedAt});

  factory RestaurantOrderTrackingTimelineItemModel.fromJson(Map<String, dynamic> json) {
    return RestaurantOrderTrackingTimelineItemModel(
      fromStatus: _asString(json['fromStatus']),
      toStatus: _asString(json['toStatus']),
      note: _asString(json['note']),
      changedAt: _asString(json['changedAt']),
    );
  }
}

class RestaurantOrderTrackingMerchantModel {
  int? id;
  String? name;
  String? primaryImageUrl;
  String? bannerImageUrl;

  RestaurantOrderTrackingMerchantModel({this.id, this.name, this.primaryImageUrl, this.bannerImageUrl});

  factory RestaurantOrderTrackingMerchantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantOrderTrackingMerchantModel(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      primaryImageUrl: _asString(json['primaryImageUrl']),
      bannerImageUrl: _asString(json['bannerImageUrl']),
    );
  }
}
