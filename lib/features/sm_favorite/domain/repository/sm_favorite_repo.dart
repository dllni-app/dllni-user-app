import 'package:common_package/helpers/typedef.dart';

import '../../../sm_discover/data/models/browse_products_model.dart';
import '../../../sm_discover/data/models/browse_stores_model.dart';
import '../usecases/get_favorite_supermarket_products_use_case.dart';
import '../usecases/get_favorite_supermarket_stores_use_case.dart';

abstract class SmFavoriteRepo {
  DataResponse<BrowseStoresModel> getFavoriteSupermarketStores(
    GetFavoriteSupermarketStoresParams params,
  );

  DataResponse<BrowseProductsModel> getFavoriteSupermarketProducts(
    GetFavoriteSupermarketProductsParams params,
  );
}
