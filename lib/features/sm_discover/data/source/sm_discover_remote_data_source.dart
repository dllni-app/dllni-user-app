import 'package:common_package/common_package.dart';
import 'package:injectable/injectable.dart';
import '../models/browse_stores_model.dart';
import '../../domain/usecases/browse_stores_use_case.dart';
import '../models/browse_products_model.dart';
import '../../domain/usecases/browse_products_use_case.dart';
import '../models/change_store_favorite_model.dart';
import '../../domain/usecases/change_store_favorite_use_case.dart';
import '../models/change_product_favorite_model.dart';
import '../../domain/usecases/change_product_favorite_use_case.dart';

@lazySingleton
class SmDiscoverRemoteDataSource with HandlingApiManager {
  final DioNetwork dioNetwork;

  SmDiscoverRemoteDataSource({required this.dioNetwork});

  Future<BrowseStoresModel> browseStores(BrowseStoresParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/supermarket/stores',
        params: params.getParams(),
        data: params.getBody().isEmpty ? null : params.getBody(),
      ),
      jsonConvert: browseStoresModelFromJson,
    );
  }

  Future<BrowseProductsModel> browseProducts(BrowseProductsParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/supermarket/products/search',
        params: params.getParams(),
        data: params.getBody().isEmpty ? null : params.getBody(),
      ),
      jsonConvert: browseProductsModelFromJson,
    );
  }

  Future<ChangeStoreFavoriteModel> changeStoreFavorite(
    ChangeStoreFavoriteParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => params.isFavorite
          ? dioNetwork.postData(
              endPoint:
                  '/api/v1/user/favorites/supermarket/stores/${params.storeId}',
              data: params.getBody(),
              params: params.getParams(),
            )
          : dioNetwork.deleteData(
              endPoint:
                  '/api/v1/user/favorites/supermarket/stores/${params.storeId}',
              data: params.getBody(),
              params: params.getParams(),
            ),
      jsonConvert: changeStoreFavoriteModelFromJson,
    );
  }

  Future<ChangeProductFavoriteModel> changeProductFavorite(
    ChangeProductFavoriteParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => params.isFavorite
          ? dioNetwork.postData(
              endPoint:
                  '/api/v1/user/favorites/supermarket/products/${params.productId}',
              data: params.getBody(),
              params: params.getParams(),
            )
          : dioNetwork.deleteData(
              endPoint:
                  '/api/v1/user/favorites/supermarket/products/${params.productId}',
              data: params.getBody(),
              params: params.getParams(),
            ),
      jsonConvert: changeProductFavoriteModelFromJson,
    );
  }
}
