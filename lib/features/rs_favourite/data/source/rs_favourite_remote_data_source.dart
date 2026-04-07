import 'package:common_package/common_package.dart';
import 'package:injectable/injectable.dart';
import '../models/fetch_favourite_products_model.dart';
import '../models/fetch_rs_favourites_model.dart';
import '../../domain/usecases/fetch_favourite_products_use_case.dart';
import '../../domain/usecases/fetch_rs_favourites_use_case.dart';

@lazySingleton
class RsFavouriteRemoteDataSource with HandlingApiManager {
  final DioNetwork dioNetwork;

  RsFavouriteRemoteDataSource({required this.dioNetwork});

  Future<FetchRsFavouritesModel> fetchRsFavourites(FetchRsFavouritesParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/favorites/restaurants',
        params: params.getParams(),
        data: params.getBody().isEmpty ? null : params.getBody(),
      ),
      jsonConvert: fetchRsFavouritesModelFromJson,
    );
  }

  Future<FetchFavouriteProductsModel> fetchFavouriteProducts(FetchFavouriteProductsParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/favorites/products',
        params: params.getParams(),
        data: params.getBody().isEmpty ? null : params.getBody(),
      ),
      jsonConvert: fetchFavouriteProductsModelFromJson,
    );
  }

  Future<bool> addRestaurantToFavourites(int restaurantId) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint: '/api/v1/user/favorites/restaurants/$restaurantId',
        data: {},
      ),
      jsonConvert: (_) => true,
    );
  }

  Future<bool> removeRestaurantFromFavourites(int restaurantId) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.deleteData(
        endPoint: '/api/v1/user/favorites/restaurants/$restaurantId',
      ),
      jsonConvert: (_) => true,
    );
  }

  Future<bool> addProductToFavourites(int productId) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint: '/api/v1/user/favorites/products/$productId',
        data: {},
      ),
      jsonConvert: (_) => true,
    );
  }

  Future<bool> removeProductFromFavourites(int productId) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.deleteData(
        endPoint: '/api/v1/user/favorites/products/$productId',
      ),
      jsonConvert: (_) => true,
    );
  }
}
