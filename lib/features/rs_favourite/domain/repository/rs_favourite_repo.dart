import 'package:common_package/helpers/typedef.dart';
import '../../data/models/fetch_favourite_products_model.dart';
import '../usecases/fetch_rs_favourites_use_case.dart';
import '../usecases/fetch_favourite_products_use_case.dart';
import '../../data/models/fetch_rs_favourites_model.dart';
abstract class RsFavouriteRepo {
  DataResponse<FetchRsFavouritesModel> fetchRsFavourites(FetchRsFavouritesParams params);
  DataResponse<FetchFavouriteProductsModel> fetchFavouriteProducts(FetchFavouriteProductsParams params);
  DataResponse<bool> addRestaurantToFavourites(int restaurantId);
  DataResponse<bool> removeRestaurantFromFavourites(int restaurantId);
  DataResponse<bool> addProductToFavourites(int productId);
  DataResponse<bool> removeProductFromFavourites(int productId);
}
