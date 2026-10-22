import 'dart:convert';

ChangeProductFavoriteModel changeProductFavoriteModelFromJson(dynamic str) =>
    ChangeProductFavoriteModel.fromJson(str);

String changeProductFavoriteModelToJson(ChangeProductFavoriteModel data) =>
    json.encode(data.toJson());

class ChangeProductFavoriteModel {
  ChangeProductFavoriteModel();

  factory ChangeProductFavoriteModel.fromJson(
    dynamic /*Map<String, dynamic>*/ json,
  ) {
    return ChangeProductFavoriteModel();
  }

  Map<String, dynamic> toJson() {
    return {};
  }
}
