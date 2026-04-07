import 'package:common_package/helpers/typedef.dart';

import '../../data/models/fetch_discover_restaurants_model.dart';
import '../../data/models/add_restaurant_cart_item_model.dart';
import '../../data/models/fetch_restaurant_cart_products_count_model.dart';
import '../../data/models/fetch_restaurant_details_model.dart';
import '../../data/models/fetch_restaurant_product_details_model.dart';
import '../params/fetch_discover_restaurants_params.dart';
import '../usecases/add_restaurant_cart_item_use_case.dart';
import '../usecases/fetch_restaurant_details_use_case.dart';
import '../usecases/fetch_restaurant_product_details_use_case.dart';

abstract class RsDiscoverRepo {
  DataResponse<FetchDiscoverRestaurantsModel> fetchDiscoverRestaurants(FetchDiscoverRestaurantsParams params);

  DataResponse<FetchRestaurantDetailsModel> fetchRestaurantDetails(FetchRestaurantDetailsParams params);

  DataResponse<FetchRestaurantProductDetailsModel> fetchRestaurantProductDetails(FetchRestaurantProductDetailsParams params);

  DataResponse<AddRestaurantCartItemModel> addRestaurantCartItem(AddRestaurantCartItemParams params);

  DataResponse<FetchRestaurantCartProductsCountModel> fetchRestaurantCartProductsCount();
}
