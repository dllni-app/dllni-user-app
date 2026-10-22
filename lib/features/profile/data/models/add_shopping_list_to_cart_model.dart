import 'dart:convert';

AddShoppingListToCartModel addShoppingListToCartModelFromJson(dynamic str) => AddShoppingListToCartModel.fromJson(str);

String addShoppingListToCartModelToJson(AddShoppingListToCartModel data) => json.encode(data.toJson());


class AddShoppingListToCartModel {

  AddShoppingListToCartModel();

  factory AddShoppingListToCartModel.fromJson(Map<String, dynamic> json) {
    return AddShoppingListToCartModel();
  }

  Map<String, dynamic> toJson() {
    return {};
  }
}
