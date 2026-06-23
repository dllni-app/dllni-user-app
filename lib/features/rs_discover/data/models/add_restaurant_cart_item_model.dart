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

AddRestaurantCartItemModel addRestaurantCartItemModelFromJson(dynamic json) =>
    AddRestaurantCartItemModel.fromJson(json is Map<String, dynamic> ? json : Map<String, dynamic>.from(json as Map));

class AddRestaurantCartItemModel {
  final String? message;
  final int? cartId;
  final int? itemId;
  final int? quantity;
  final int? cartProductsCount;
  final String? operation;

  AddRestaurantCartItemModel({
    this.message,
    this.cartId,
    this.itemId,
    this.quantity,
    this.cartProductsCount,
    this.operation,
  });

  factory AddRestaurantCartItemModel.fromJson(Map<String, dynamic> json) {
    return AddRestaurantCartItemModel(
      message: _asString(json['message']),
      cartId: _asInt(json['cartId']),
      itemId: _asInt(json['itemId']),
      quantity: _asInt(json['quantity']),
      cartProductsCount: _asInt(json['cartProductsCount'] ?? json['cart_products_count']),
      operation: _asString(json['operation']),
    );
  }

  Map<String, dynamic> toJson() => {
        'message': message,
        'cartId': cartId,
        'itemId': itemId,
        'quantity': quantity,
        'cartProductsCount': cartProductsCount,
        'operation': operation,
      };
}
