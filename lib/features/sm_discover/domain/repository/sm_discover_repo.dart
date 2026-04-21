import 'package:common_package/helpers/typedef.dart';
import '../usecases/browse_stores_use_case.dart';
import '../../data/models/browse_stores_model.dart';
import '../usecases/browse_products_use_case.dart';
import '../../data/models/browse_products_model.dart';
import '../usecases/change_store_favorite_use_case.dart';
import '../../data/models/change_store_favorite_model.dart';
import '../usecases/change_product_favorite_use_case.dart';
import '../../data/models/change_product_favorite_model.dart';
import '../usecases/normalize_product_text_use_case.dart';
import '../../data/models/normalize_product_text_model.dart';
abstract class SmDiscoverRepo {
  DataResponse<BrowseStoresModel> browseStores(BrowseStoresParams params);

  DataResponse<BrowseProductsModel> browseProducts(BrowseProductsParams params);

  DataResponse<ChangeStoreFavoriteModel> changeStoreFavorite(ChangeStoreFavoriteParams params);

  DataResponse<ChangeProductFavoriteModel> changeProductFavorite(ChangeProductFavoriteParams params);

  DataResponse<NormalizeProductTextModel> normalizeProductText(NormalizeProductTextParams params);
}
