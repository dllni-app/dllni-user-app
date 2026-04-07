import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/error_handler.dart';

import '../../domain/repository/sm_discover_repo.dart';
import 'package:common_package/helpers/typedef.dart';
import '../source/sm_discover_remote_data_source.dart';
import '../../domain/usecases/browse_stores_use_case.dart';
import '../models/browse_stores_model.dart';
import '../../domain/usecases/browse_products_use_case.dart';
import '../models/browse_products_model.dart';
import '../../domain/usecases/change_store_favorite_use_case.dart';
import '../models/change_store_favorite_model.dart';
import '../../domain/usecases/change_product_favorite_use_case.dart';
import '../models/change_product_favorite_model.dart';

@LazySingleton(as: SmDiscoverRepo)
class SmDiscoverRepoImpl with HandlingException implements SmDiscoverRepo {
  final SmDiscoverRemoteDataSource smDiscoverRemoteDataSource;

  SmDiscoverRepoImpl({required this.smDiscoverRemoteDataSource});

  @override
  DataResponse<BrowseStoresModel> browseStores(BrowseStoresParams params) {
    return wrapHandlingException(
      tryCall: () => smDiscoverRemoteDataSource.browseStores(params),
    );
  }

  @override
  DataResponse<BrowseProductsModel> browseProducts(BrowseProductsParams params) {
    return wrapHandlingException(
      tryCall: () => smDiscoverRemoteDataSource.browseProducts(params),
    );
  }

  @override
  DataResponse<ChangeStoreFavoriteModel> changeStoreFavorite(ChangeStoreFavoriteParams params) {
    return wrapHandlingException(
      tryCall: () => smDiscoverRemoteDataSource.changeStoreFavorite(params),
    );
  }

  @override
  DataResponse<ChangeProductFavoriteModel> changeProductFavorite(ChangeProductFavoriteParams params) {
    return wrapHandlingException(
      tryCall: () => smDiscoverRemoteDataSource.changeProductFavorite(params),
    );
  }}

