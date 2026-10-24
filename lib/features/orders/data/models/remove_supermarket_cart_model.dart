import 'dart:convert';

RemoveSupermarketCartModel removeSupermarketCartModelFromJson(dynamic str) => RemoveSupermarketCartModel.fromJson(str);

String removeSupermarketCartModelToJson(RemoveSupermarketCartModel data) => json.encode(data.toJson());


class RemoveSupermarketCartModel {

  RemoveSupermarketCartModel();

  factory RemoveSupermarketCartModel.fromJson(Map<String, dynamic> json) {
    return RemoveSupermarketCartModel();
  }

  Map<String, dynamic> toJson() {
    return {};
  }
}
