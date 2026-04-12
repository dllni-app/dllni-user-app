import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/get_supermarket_product_details_model.dart';
import '../repository/sm_stores_repo.dart';

@lazySingleton
class GetSupermarketProductDetailsUseCase
    implements
        UseCase<
          GetSupermarketProductDetailsModel,
          GetSupermarketProductDetailsParams
        > {
  final SmStoresRepo smStores;

  GetSupermarketProductDetailsUseCase({required this.smStores});

  @override
  DataResponse<GetSupermarketProductDetailsModel> call(
    GetSupermarketProductDetailsParams params,
  ) {
    return smStores.getSupermarketProductDetails(params);
  }
}

class GetSupermarketProductDetailsParams with Params {
  final int productId;

  GetSupermarketProductDetailsParams({required this.productId});
}
