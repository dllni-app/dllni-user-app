import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/typedef.dart';

import '../repository/sm_stores_repo.dart';
import '../../data/models/get_compare_products_model.dart';

@lazySingleton
class GetCompareProductsUseCase
    implements UseCase<GetCompareProductsModel, GetCompareProductsParams> {
  final SmStoresRepo smStores;

  GetCompareProductsUseCase({required this.smStores});

  @override
  DataResponse<GetCompareProductsModel> call(GetCompareProductsParams params) {
    return smStores.getCompareProducts(params);
  }
}

class GetCompareProductsParams with Params {
  final int page;
  final int productId;

  GetCompareProductsParams({this.page = 1, required this.productId});

  @override
  QueryParams getParams() => {'page': page, 'per_page': 10};
}
