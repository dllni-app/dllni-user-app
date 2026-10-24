import 'dart:convert';

ChangeStoreFavoriteModel changeStoreFavoriteModelFromJson(dynamic str) =>
    ChangeStoreFavoriteModel.fromJson(str);

String changeStoreFavoriteModelToJson(ChangeStoreFavoriteModel data) =>
    json.encode(data.toJson());

class ChangeStoreFavoriteModel {
  ChangeStoreFavoriteModel();

  factory ChangeStoreFavoriteModel.fromJson(
    dynamic /*Map<String, dynamic>*/ json,
  ) {
    return ChangeStoreFavoriteModel();
  }

  Map<String, dynamic> toJson() {
    return {};
  }
}
