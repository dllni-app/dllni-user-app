import 'package:common_package/helpers/typedef.dart';

import '../../data/models/get_supermarket_product_details_model.dart';
import '../../data/models/get_supermarket_store_details_model.dart';
import '../usecases/get_supermarket_product_details_use_case.dart';
import '../usecases/get_supermarket_store_details_use_case.dart';
import '../usecases/get_compare_products_use_case.dart';
import '../../data/models/get_compare_products_model.dart';

abstract class SmStoresRepo {
  DataResponse<GetSupermarketStoreDetailsModel> getSupermarketStoreDetails(
    GetSupermarketStoreDetailsParams params,
  );

  DataResponse<GetSupermarketProductDetailsModel> getSupermarketProductDetails(
    GetSupermarketProductDetailsParams params,
  );

  DataResponse<GetCompareProductsModel> getCompareProducts(GetCompareProductsParams params);
}
