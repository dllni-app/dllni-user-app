import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/fetch_restaurant_home_latest_ordered_products_model.dart';
import '../repository/rs_home_repo.dart';

@lazySingleton
class FetchRestaurantHomeLatestOrderedProductsUseCase
    implements UseCase<FetchRestaurantHomeLatestOrderedProductsModel, FetchRestaurantHomeLatestOrderedProductsParams> {
  final RsHomeRepo rsHomeRepo;

  FetchRestaurantHomeLatestOrderedProductsUseCase({required this.rsHomeRepo});

  @override
  DataResponse<FetchRestaurantHomeLatestOrderedProductsModel> call(FetchRestaurantHomeLatestOrderedProductsParams params) {
    return rsHomeRepo.fetchRestaurantHomeLatestOrderedProducts(params);
  }
}

class FetchRestaurantHomeLatestOrderedProductsParams with Params {
  final int limit;

  FetchRestaurantHomeLatestOrderedProductsParams({this.limit = 15});

  @override
  QueryParams getParams() => {'limit': limit};
}
