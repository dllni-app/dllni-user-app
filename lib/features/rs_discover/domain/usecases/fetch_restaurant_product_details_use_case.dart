import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/fetch_restaurant_product_details_model.dart';
import '../repository/rs_discover_repo.dart';

@lazySingleton
class FetchRestaurantProductDetailsUseCase implements UseCase<FetchRestaurantProductDetailsModel, FetchRestaurantProductDetailsParams> {
  final RsDiscoverRepo rsDiscoverRepo;

  FetchRestaurantProductDetailsUseCase({required this.rsDiscoverRepo});

  @override
  DataResponse<FetchRestaurantProductDetailsModel> call(FetchRestaurantProductDetailsParams params) {
    return rsDiscoverRepo.fetchRestaurantProductDetails(params);
  }
}

class FetchRestaurantProductDetailsParams with Params {
  final int productId;

  FetchRestaurantProductDetailsParams({required this.productId});
}
