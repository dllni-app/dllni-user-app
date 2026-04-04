import 'package:common_package/helpers/typedef.dart';

import '../../data/models/fetch_discover_restaurants_model.dart';
import '../../data/models/fetch_restaurant_details_model.dart';
import '../../data/models/fetch_restaurant_product_details_model.dart';
import '../params/fetch_discover_restaurants_params.dart';
import '../usecases/fetch_restaurant_details_use_case.dart';
import '../usecases/fetch_restaurant_product_details_use_case.dart';

abstract class RsDiscoverRepo {
  DataResponse<FetchDiscoverRestaurantsModel> fetchDiscoverRestaurants(FetchDiscoverRestaurantsParams params);

  DataResponse<FetchRestaurantDetailsModel> fetchRestaurantDetails(FetchRestaurantDetailsParams params);

  DataResponse<FetchRestaurantProductDetailsModel> fetchRestaurantProductDetails(FetchRestaurantProductDetailsParams params);
}
