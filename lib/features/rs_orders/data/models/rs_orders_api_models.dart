int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value');
}

num? _asNum(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  return num.tryParse('$value');
}

String? _asString(dynamic value) {
  if (value == null) return null;
  return '$value';
}

FetchOrdersListModel fetchOrdersListModelFromJson(dynamic json) => FetchOrdersListModel.fromJson(Map<String, dynamic>.from(json as Map));

FetchOrderDetailsModel fetchOrderDetailsModelFromJson(dynamic json) =>
    FetchOrderDetailsModel.fromJson(Map<String, dynamic>.from(json as Map));

CheckoutOrderModel checkoutOrderModelFromJson(dynamic json) => CheckoutOrderModel.fromJson(Map<String, dynamic>.from(json as Map));

AddCartItemModel addCartItemModelFromJson(dynamic json) => AddCartItemModel.fromJson(Map<String, dynamic>.from(json as Map));

class OrderRestaurantSnippet {
  final int? id;
  final String? name;

  const OrderRestaurantSnippet({this.id, this.name});

  factory OrderRestaurantSnippet.fromJson(Map<String, dynamic> json) {
    return OrderRestaurantSnippet(
      id: _asInt(json['id']),
      name: _asString(json['name']),
    );
  }
}

class OrderProductSnippet {
  final int? id;
  final String? name;

  const OrderProductSnippet({this.id, this.name});

  factory OrderProductSnippet.fromJson(Map<String, dynamic> json) {
    return OrderProductSnippet(
      id: _asInt(json['id']),
      name: _asString(json['name']),
    );
  }
}

class OrderLineItem {
  final int? id;
  final int? quantity;
  final OrderProductSnippet? product;

  const OrderLineItem({this.id, this.quantity, this.product});

  factory OrderLineItem.fromJson(Map<String, dynamic> json) {
    return OrderLineItem(
      id: _asInt(json['id']),
      quantity: _asInt(json['quantity']),
      product: json['product'] is Map ? OrderProductSnippet.fromJson(Map<String, dynamic>.from(json['product'] as Map)) : null,
    );
  }
}

class OrderResourceModel {
  final int? id;
  final int? userId;
  final int? restaurantId;
  final String? orderNumber;
  final String? status;
  final String? statusLabelAr;
  final String? orderType;
  final String? pickupMode;
  final num? subtotal;
  final num? totalAmount;
  final OrderRestaurantSnippet? restaurant;
  final List<OrderLineItem>? orderItems;

  const OrderResourceModel({
    this.id,
    this.userId,
    this.restaurantId,
    this.orderNumber,
    this.status,
    this.statusLabelAr,
    this.orderType,
    this.pickupMode,
    this.subtotal,
    this.totalAmount,
    this.restaurant,
    this.orderItems,
  });

  factory OrderResourceModel.fromJson(Map<String, dynamic> json) {
    return OrderResourceModel(
      id: _asInt(json['id']),
      userId: _asInt(json['userId']),
      restaurantId: _asInt(json['restaurantId']),
      orderNumber: _asString(json['orderNumber']),
      status: _asString(json['status']),
      statusLabelAr: _asString(json['statusLabelAr']),
      orderType: _asString(json['orderType']),
      pickupMode: _asString(json['pickupMode']),
      subtotal: _asNum(json['subtotal']),
      totalAmount: _asNum(json['totalAmount']),
      restaurant: json['restaurant'] is Map ? OrderRestaurantSnippet.fromJson(Map<String, dynamic>.from(json['restaurant'] as Map)) : null,
      orderItems: json['orderItems'] is List
          ? (json['orderItems'] as List).whereType<Map>().map((e) => OrderLineItem.fromJson(Map<String, dynamic>.from(e))).toList()
          : null,
    );
  }
}

class PaginationMeta {
  final int? currentPage;
  final int? perPage;
  final int? total;

  const PaginationMeta({this.currentPage, this.perPage, this.total});

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: _asInt(json['current_page']),
      perPage: _asInt(json['per_page']),
      total: _asInt(json['total']),
    );
  }
}

class FetchOrdersListModel {
  final List<OrderResourceModel>? data;
  final PaginationMeta? meta;

  const FetchOrdersListModel({this.data, this.meta});

  factory FetchOrdersListModel.fromJson(Map<String, dynamic> json) {
    return FetchOrdersListModel(
      data: json['data'] is List
          ? (json['data'] as List).whereType<Map>().map((e) => OrderResourceModel.fromJson(Map<String, dynamic>.from(e))).toList()
          : null,
      meta: json['meta'] is Map ? PaginationMeta.fromJson(Map<String, dynamic>.from(json['meta'] as Map)) : null,
    );
  }
}

class FetchOrderDetailsModel {
  final OrderResourceModel? data;

  const FetchOrderDetailsModel({this.data});

  factory FetchOrderDetailsModel.fromJson(Map<String, dynamic> json) {
    return FetchOrderDetailsModel(
      data: json['data'] is Map ? OrderResourceModel.fromJson(Map<String, dynamic>.from(json['data'] as Map)) : null,
    );
  }
}

class CheckoutOrderModel {
  final String? message;
  final OrderResourceModel? order;

  const CheckoutOrderModel({this.message, this.order});

  factory CheckoutOrderModel.fromJson(Map<String, dynamic> json) {
    return CheckoutOrderModel(
      message: _asString(json['message']),
      order: json['order'] is Map ? OrderResourceModel.fromJson(Map<String, dynamic>.from(json['order'] as Map)) : null,
    );
  }
}

class AddCartItemModel {
  final String? message;
  final int? cartId;
  final int? itemId;

  const AddCartItemModel({this.message, this.cartId, this.itemId});

  factory AddCartItemModel.fromJson(Map<String, dynamic> json) {
    return AddCartItemModel(
      message: _asString(json['message']),
      cartId: _asInt(json['cartId']),
      itemId: _asInt(json['itemId']),
    );
  }
}
