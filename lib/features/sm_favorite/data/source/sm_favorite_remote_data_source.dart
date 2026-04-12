import 'package:common_package/common_package.dart';
import 'package:injectable/injectable.dart';

import '../../../sm_discover/data/models/browse_products_model.dart';
import '../../../sm_discover/data/models/browse_stores_model.dart';
import '../../domain/usecases/get_favorite_supermarket_products_use_case.dart';
import '../../domain/usecases/get_favorite_supermarket_stores_use_case.dart';

@lazySingleton
class SmFavoriteRemoteDataSource with HandlingApiManager {
  final DioNetwork dioNetwork;

  SmFavoriteRemoteDataSource({required this.dioNetwork});

  Future<BrowseStoresModel> getFavoriteSupermarketStores(
    GetFavoriteSupermarketStoresParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/favorites/supermarket/stores',
        params: params.getParams(),
      ),
      jsonConvert: browseStoresModelFromJson,
    );
  }

  Future<BrowseProductsModel> getFavoriteSupermarketProducts(
    GetFavoriteSupermarketProductsParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/favorites/supermarket/products',
        params: params.getParams(),
      ),
      jsonConvert: browseProductsModelFromJson,
    );
  }
}