import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/error_handler.dart';

import '../../domain/repository/rs_favourite_repo.dart';
import 'package:common_package/helpers/typedef.dart';
import '../models/fetch_favourite_products_model.dart';
import '../source/rs_favourite_remote_data_source.dart';
import '../../domain/usecases/fetch_favourite_products_use_case.dart';
import '../../domain/usecases/fetch_rs_favourites_use_case.dart';
import '../models/fetch_rs_favourites_model.dart';

@LazySingleton(as: RsFavouriteRepo)
class RsFavouriteRepoImpl with HandlingException implements RsFavouriteRepo {
  final RsFavouriteRemoteDataSource rsFavouriteRemoteDataSource;

  RsFavouriteRepoImpl({required this.rsFavouriteRemoteDataSource});

  @override
  DataResponse<FetchRsFavouritesModel> fetchRsFavourites(FetchRsFavouritesParams params) {
    return wrapHandlingException(
      tryCall: () => rsFavouriteRemoteDataSource.fetchRsFavourites(params),
    );
  }

  @override
  DataResponse<FetchFavouriteProductsModel> fetchFavouriteProducts(FetchFavouriteProductsParams params) {
    return wrapHandlingException(
      tryCall: () => rsFavouriteRemoteDataSource.fetchFavouriteProducts(params),
    );
  }

  @override
  DataResponse<bool> addRestaurantToFavourites(int restaurantId) {
    return wrapHandlingException(
      tryCall: () => rsFavouriteRemoteDataSource.addRestaurantToFavourites(restaurantId),
    );
  }

  @override
  DataResponse<bool> removeRestaurantFromFavourites(int restaurantId) {
    return wrapHandlingException(
      tryCall: () => rsFavouriteRemoteDataSource.removeRestaurantFromFavourites(restaurantId),
    );
  }

  @override
  DataResponse<bool> addProductToFavourites(int productId) {
    return wrapHandlingException(
      tryCall: () => rsFavouriteRemoteDataSource.addProductToFavourites(productId),
    );
  }

  @override
  DataResponse<bool> removeProductFromFavourites(int productId) {
    return wrapHandlingException(
      tryCall: () => rsFavouriteRemoteDataSource.removeProductFromFavourites(productId),
    );
  }
}

