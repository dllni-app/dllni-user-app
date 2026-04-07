import 'package:common_package/helpers/typedef.dart';
import '../usecases/fetch_stores_use_case.dart';
import '../../data/models/fetch_stores_model.dart';
import '../usecases/fetch_near_by_stores_use_case.dart';
import '../../data/models/fetch_near_by_stores_model.dart';
import '../usecases/fetch_featured_offers_use_case.dart';
import '../../data/models/fetch_featured_offers_model.dart';
import '../usecases/fetch_restaurant_home_categories_use_case.dart';
import '../../data/models/fetch_restaurant_home_categories_model.dart';
import '../usecases/fetch_restaurant_home_exclusive_offers_use_case.dart';
import '../../data/models/fetch_restaurant_home_exclusive_offers_model.dart';
import '../usecases/fetch_restaurant_home_suggested_products_use_case.dart';
import '../../data/models/fetch_restaurant_home_suggested_products_model.dart';
import '../usecases/fetch_restaurant_home_nearest_restaurants_use_case.dart';
import '../../data/models/fetch_restaurant_home_nearest_restaurants_model.dart';
import '../usecases/fetch_restaurant_home_latest_ordered_products_use_case.dart';
import '../../data/models/fetch_restaurant_home_latest_ordered_products_model.dart';
import '../usecases/fetch_restaurant_home_category_products_use_case.dart';
import '../../data/models/fetch_restaurant_home_category_products_model.dart';

abstract class RsHomeRepo {
  DataResponse<FetchStoresModel> fetchStores(FetchStoresParams params);

  DataResponse<FetchNearByStoresModel> fetchNearByStores(
    FetchNearByStoresParams params,
  );

  DataResponse<FetchFeaturedOffersModel> fetchFeaturedOffers(
    FetchFeaturedOffersParams params,
  );

  DataResponse<FetchRestaurantHomeCategoriesModel>
  fetchRestaurantHomeCategories(FetchRestaurantHomeCategoriesParams params);

  DataResponse<FetchRestaurantHomeExclusiveOffersModel>
  fetchRestaurantHomeExclusiveOffers(
    FetchRestaurantHomeExclusiveOffersParams params,
  );

  DataResponse<FetchRestaurantHomeSuggestedProductsModel>
  fetchRestaurantHomeSuggestedProducts(
    FetchRestaurantHomeSuggestedProductsParams params,
  );

  DataResponse<FetchRestaurantHomeNearestRestaurantsModel>
  fetchRestaurantHomeNearestRestaurants(
    FetchRestaurantHomeNearestRestaurantsParams params,
  );

  DataResponse<FetchRestaurantHomeLatestOrderedProductsModel>
  fetchRestaurantHomeLatestOrderedProducts(
    FetchRestaurantHomeLatestOrderedProductsParams params,
  );

  DataResponse<FetchRestaurantHomeCategoryProductsModel>
  fetchRestaurantHomeCategoryProducts(
    FetchRestaurantHomeCategoryProductsParams params,
  );

  DataResponse<bool> reorderLatestOrderedProduct();
}
