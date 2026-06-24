import 'package:common_package/helpers/typedef.dart';

import 'orders_api_models.dart';

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

double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

String? _asString(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is num || value is bool) return value.toString();
  return null;
}

FetchMerchantCartsModel fetchMerchantCartsModelFromJson(dynamic json) =>
    FetchMerchantCartsModel.fromJson(_asMap(json));

FetchRestaurantCartModel fetchMerchantCartModelFromJson(dynamic json) =>
    FetchRestaurantCartModel.fromJson(_asMap(json));

CheckoutPreviewModel checkoutPreviewModelFromJson(dynamic json) =>
    CheckoutPreviewModel.fromJson(_asMap(json));

class FetchMerchantCartsModel {
  final List<RestaurantCartDataModel> data;

  FetchMerchantCartsModel({required this.data});

  factory FetchMerchantCartsModel.fromJson(Map<String, dynamic> json) {
    return FetchMerchantCartsModel(
      data: _asMapList(json['data'])
          .map(RestaurantCartDataModel.fromJson)
          .toList(),
    );
  }
}

class CheckoutPreviewModel {
  final CheckoutPreviewDataModel? data;

  CheckoutPreviewModel({this.data});

  factory CheckoutPreviewModel.fromJson(Map<String, dynamic> json) {
    return CheckoutPreviewModel(
      data: json['data'] == null
          ? null
          : CheckoutPreviewDataModel.fromJson(_asMap(json['data'])),
    );
  }
}

class CheckoutPreviewDataModel {
  final int? cartId;
  final OrderMerchantModel? merchant;
  final OrderFulfillmentModel? fulfillment;
  final CheckoutPreviewAmountsModel? amounts;
  final String? note;

  CheckoutPreviewDataModel({
    this.cartId,
    this.merchant,
    this.fulfillment,
    this.amounts,
    this.note,
  });

  factory CheckoutPreviewDataModel.fromJson(Map<String, dynamic> json) {
    return CheckoutPreviewDataModel(
      cartId: json['cartId'] is int
          ? json['cartId'] as int
          : int.tryParse('${json['cartId'] ?? ''}'),
      merchant: json['merchant'] == null
          ? null
          : OrderMerchantModel.fromJson(_asMap(json['merchant'])),
      fulfillment: json['fulfillment'] == null
          ? null
          : OrderFulfillmentModel.fromJson(_asMap(json['fulfillment'])),
      amounts: json['amounts'] == null
          ? null
          : CheckoutPreviewAmountsModel.fromJson(_asMap(json['amounts'])),
      note: _asString(json['note']),
    );
  }
}

class CheckoutPreviewAmountsModel {
  final double subtotal;
  final double discount;
  final double serviceFee;
  final double tax;
  final double total;

  CheckoutPreviewAmountsModel({
    this.subtotal = 0,
    this.discount = 0,
    this.serviceFee = 0,
    this.tax = 0,
    this.total = 0,
  });

  factory CheckoutPreviewAmountsModel.fromJson(Map<String, dynamic> json) {
    return CheckoutPreviewAmountsModel(
      subtotal: _asDouble(json['subtotal']) ?? 0,
      discount: _asDouble(json['discount']) ?? 0,
      serviceFee: _asDouble(json['serviceFee']) ?? 0,
      tax: _asDouble(json['tax']) ?? 0,
      total: _asDouble(json['total']) ?? 0,
    );
  }
}

class FetchMerchantCartByIdParams {
  final int cartId;

  FetchMerchantCartByIdParams({required this.cartId});
}

class CheckoutPreviewParams with Params {
  final int cartId;
  final String fulfillmentType;
  final String receiveMode;
  final String? scheduledAt;
  final int? addressId;
  final String? couponCode;
  final String? note;

  CheckoutPreviewParams({
    required this.cartId,
    required this.fulfillmentType,
    required this.receiveMode,
    this.scheduledAt,
    this.addressId,
    this.couponCode,
    this.note,
  });

  @override
  BodyMap getBody() {
    final body = <String, dynamic>{
      'fulfillmentType': fulfillmentType,
      'receiveMode': receiveMode,
      'addressId': addressId,
    };

    final schedule = scheduledAt;
    if (receiveMode == 'scheduled' && schedule != null && schedule.isNotEmpty) {
      body['scheduledAt'] = schedule;
    }

    final coupon = couponCode;
    if (coupon != null && coupon.trim().isNotEmpty) {
      body['couponCode'] = coupon;
    }

    final orderNote = note;
    if (orderNote != null && orderNote.trim().isNotEmpty) {
      body['note'] = orderNote;
    }

    return body;
  }
}

extension RestaurantCartDataModelMerchantScoped on RestaurantCartDataModel {
  int get productsCount =>
      items.fold<int>(0, (sum, item) => sum + item.quantity);
}
