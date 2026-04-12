import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/get_supermarket_store_details_model.dart';
import '../repository/sm_stores_repo.dart';

@lazySingleton
class GetSupermarketStoreDetailsUseCase
    implements
        UseCase<GetSupermarketStoreDetailsModel, GetSupermarketStoreDetailsParams> {
  final SmStoresRepo smStores;

  GetSupermarketStoreDetailsUseCase({required this.smStores});

  @override
  DataResponse<GetSupermarketStoreDetailsModel> call(
    GetSupermarketStoreDetailsParams params,
  ) {
    return smStores.getSupermarketStoreDetails(params);
  }
}

class GetSupermarketStoreDetailsParams with Params {
  final int storeId;

  GetSupermarketStoreDetailsParams({required this.storeId});
}
