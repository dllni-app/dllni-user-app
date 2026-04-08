import 'package:common_package/helpers/error_handler.dart';
import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/get_supermarket_product_details_model.dart';
import '../../data/models/get_supermarket_store_details_model.dart';
import '../../domain/repository/sm_stores_repo.dart';
import '../../domain/usecases/get_supermarket_product_details_use_case.dart';
import '../../domain/usecases/get_supermarket_store_details_use_case.dart';
import '../source/sm_stores_remote_data_source.dart';
import '../../domain/usecases/get_compare_products_use_case.dart';
import '../models/get_compare_products_model.dart';

@LazySingleton(as: SmStoresRepo)
class SmStoresRepoImpl with HandlingException implements SmStoresRepo {
  final SmStoresRemoteDataSource smStoresRemoteDataSource;

  SmStoresRepoImpl({required this.smStoresRemoteDataSource});

  @override
  DataResponse<GetSupermarketStoreDetailsModel> getSupermarketStoreDetails(
    GetSupermarketStoreDetailsParams params,
  ) {
    return wrapHandlingException(
      tryCall: () =>
          smStoresRemoteDataSource.getSupermarketStoreDetails(params),
    );
  }

  @override
  DataResponse<GetSupermarketProductDetailsModel> getSupermarketProductDetails(
    GetSupermarketProductDetailsParams params,
  ) {
    return wrapHandlingException(
      tryCall: () =>
          smStoresRemoteDataSource.getSupermarketProductDetails(params),
    );
  }


  @override
  DataResponse<GetCompareProductsModel> getCompareProducts(GetCompareProductsParams params) {
    return wrapHandlingException(
      tryCall: () => smStoresRemoteDataSource.getCompareProducts(params),
    );
  }}
