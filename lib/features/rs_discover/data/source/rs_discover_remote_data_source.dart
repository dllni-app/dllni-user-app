import 'package:common_package/common_package.dart';
import 'package:injectable/injectable.dart';

import '../models/fetch_discover_restaurants_model.dart';
import '../models/fetch_restaurant_details_model.dart';
import '../models/fetch_restaurant_product_details_model.dart';
import '../../domain/params/fetch_discover_restaurants_params.dart';
import '../../domain/usecases/fetch_restaurant_details_use_case.dart';
import '../../domain/usecases/fetch_restaurant_product_details_use_case.dart';

@lazySingleton
class RsDiscoverRemoteDataSource with HandlingApiManager {
  final DioNetwork dioNetwork;

  RsDiscoverRemoteDataSource({required this.dioNetwork});

  Future<FetchDiscoverRestaurantsModel> fetchDiscoverRestaurants(FetchDiscoverRestaurantsParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/restaurants/discover',
        params: params.getParams(),
        data: params.getBody().isEmpty ? null : params.getBody(),
      ),
      jsonConvert: fetchDiscoverRestaurantsModelFromJson,
    );
  }

  Future<FetchRestaurantDetailsModel> fetchRestaurantDetails(FetchRestaurantDetailsParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/restaurants/${params.restaurantId}',
        params: params.getParams(),
        data: params.getBody().isEmpty ? null : params.getBody(),
      ),
      jsonConvert: fetchRestaurantDetailsModelFromJson,
    );
  }

  Future<FetchRestaurantProductDetailsModel> fetchRestaurantProductDetails(FetchRestaurantProductDetailsParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/products/${params.productId}',
        params: params.getParams(),
        data: params.getBody().isEmpty ? null : params.getBody(),
      ),
      jsonConvert: fetchRestaurantProductDetailsModelFromJson,
    );
  }
}
