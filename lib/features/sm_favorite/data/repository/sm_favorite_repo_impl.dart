import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/error_handler.dart';
import 'package:common_package/helpers/typedef.dart';

import '../../../sm_discover/data/models/browse_products_model.dart';
import '../../../sm_discover/data/models/browse_stores_model.dart';
import '../../domain/usecases/get_favorite_supermarket_products_use_case.dart';
import '../../domain/usecases/get_favorite_supermarket_stores_use_case.dart';
import '../../domain/repository/sm_favorite_repo.dart';
import '../source/sm_favorite_remote_data_source.dart';

@LazySingleton(as: SmFavoriteRepo)
class SmFavoriteRepoImpl with HandlingException implements SmFavoriteRepo {
  final SmFavoriteRemoteDataSource smFavoriteRemoteDataSource;

  SmFavoriteRepoImpl({required this.smFavoriteRemoteDataSource});

  @override
  DataResponse<BrowseStoresModel> getFavoriteSupermarketStores(
    GetFavoriteSupermarketStoresParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => smFavoriteRemoteDataSource.getFavoriteSupermarketStores(
        params,
      ),
    );
  }

  @override
  DataResponse<BrowseProductsModel> getFavoriteSupermarketProducts(
    GetFavoriteSupermarketProductsParams params,
  ) {
    return wrapHandlingException(
      tryCall: () =>
          smFavoriteRemoteDataSource.getFavoriteSupermarketProducts(params),
    );
  }
}

