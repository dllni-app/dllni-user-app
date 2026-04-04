import 'restaurant_home_shared_parser.dart';

FetchRestaurantHomeCategoriesModel fetchRestaurantHomeCategoriesModelFromJson(dynamic json) =>
    FetchRestaurantHomeCategoriesModel.fromJson(Map<String, dynamic>.from(json as Map));

class FetchRestaurantHomeCategoriesModel {
  final List<RestaurantHomeCategoryItem>? categories;

  FetchRestaurantHomeCategoriesModel({this.categories});

  factory FetchRestaurantHomeCategoriesModel.fromJson(Map<String, dynamic> json) {
    return FetchRestaurantHomeCategoriesModel(
      categories: json['categories'] is List
          ? (json['categories'] as List)
              .whereType<Map>()
              .map((e) => RestaurantHomeCategoryItem.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : null,
    );
  }
}

class RestaurantHomeCategoryItem {
  final int? id;
  final String? name;
  final String? slug;

  RestaurantHomeCategoryItem({this.id, this.name, this.slug});

  factory RestaurantHomeCategoryItem.fromJson(Map<String, dynamic> json) {
    return RestaurantHomeCategoryItem(
      id: rsHomeAsInt(json['id']),
      name: rsHomeAsString(json['name']),
      slug: rsHomeAsString(json['slug']),
    );
  }
}
