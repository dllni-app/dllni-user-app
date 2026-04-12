import 'package:common_package/common_package.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/get_supermarket_product_details_use_case.dart';
import '../../domain/usecases/get_supermarket_store_details_use_case.dart';
import '../../domain/usecases/add_supermarket_cart_item_use_case.dart';
import '../models/add_supermarket_cart_item_model.dart';
import '../models/get_supermarket_product_details_model.dart';
import '../models/get_supermarket_store_details_model.dart';
import '../models/get_compare_products_model.dart';
import '../../domain/usecases/get_compare_products_use_case.dart';

@lazySingleton
class SmStoresRemoteDataSource with HandlingApiManager {
  final DioNetwork dioNetwork;

  SmStoresRemoteDataSource({required this.dioNetwork});

  Future<GetSupermarketStoreDetailsModel> getSupermarketStoreDetails(
    GetSupermarketStoreDetailsParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/supermarket/stores/${params.storeId}',
        params: params.getParams(),
      ),
      jsonConvert: getSupermarketStoreDetailsModelFromJson,
    );
  }

  Future<GetSupermarketProductDetailsModel> getSupermarketProductDetails(
    GetSupermarketProductDetailsParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/supermarket/products/${params.productId}',
        params: params.getParams(),
      ),
      jsonConvert: getSupermarketProductDetailsModelFromJson,
    );
  }

  Future<GetCompareProductsModel> getCompareProducts(
    GetCompareProductsParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint:
            '/api/v1/user/supermarket/products/${params.productId}/compare',
        params: params.getParams(),
        data: params.getBody().isEmpty ? null : params.getBody(),
      ),
      jsonConvert: getCompareProductsModelFromJson,
    );
  }

  Future<AddSupermarketCartItemModel> addSupermarketCartItem(
    AddSupermarketCartItemParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint: '/api/v1/user/supermarket/cart/items',
        data: params.getBody(),
      ),
      jsonConvert: addSupermarketCartItemModelFromJson,
    );
  }
}
