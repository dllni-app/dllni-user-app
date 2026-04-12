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

AddSupermarketCartItemModel addSupermarketCartItemModelFromJson(dynamic json) =>
    AddSupermarketCartItemModel.fromJson(
      json is Map<String, dynamic>
          ? json
          : (json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{}),
    );

class AddSupermarketCartItemModel {
  final String? message;
  final int? cartId;
  final int? itemId;

  AddSupermarketCartItemModel({
    this.message,
    this.cartId,
    this.itemId,
  });

  factory AddSupermarketCartItemModel.fromJson(Map<String, dynamic> json) {
    return AddSupermarketCartItemModel(
      message: _asString(json['message']),
      cartId: _asInt(json['cartId']),
      itemId: _asInt(json['itemId']),
    );
  }
}
