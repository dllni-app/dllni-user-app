import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/fetch_restaurant_cart_products_count_model.dart';
import '../repository/rs_discover_repo.dart';

@lazySingleton
class FetchRestaurantCartProductsCountUseCase
    implements
        UseCase<
          FetchRestaurantCartProductsCountModel,
          FetchRestaurantCartProductsCountParams
        > {
  final RsDiscoverRepo rsDiscoverRepo;

  FetchRestaurantCartProductsCountUseCase({
    required this.rsDiscoverRepo,
  });

  @override
  DataResponse<FetchRestaurantCartProductsCountModel> call(
    FetchRestaurantCartProductsCountParams params,
  ) {
    return rsDiscoverRepo.fetchRestaurantCartProductsCount();
  }
}

class FetchRestaurantCartProductsCountParams with Params {}
