import 'dart:convert';

DeleteSupermarketCartModel deleteSupermarketCartModelFromJson(dynamic str) => DeleteSupermarketCartModel.fromJson(str);

String deleteSupermarketCartModelToJson(DeleteSupermarketCartModel data) => json.encode(data.toJson());


class DeleteSupermarketCartModel {

  DeleteSupermarketCartModel();

  factory DeleteSupermarketCartModel.fromJson(Map<String, dynamic> json) {
    return DeleteSupermarketCartModel();
  }

  Map<String, dynamic> toJson() {
    return {};
  }
}
