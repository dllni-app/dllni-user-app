import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/merchant_cart_models.dart';
import '../repository/orders_repo.dart';

@lazySingleton
class FetchRestaurantCartUseCase
    implements UseCase<FetchMerchantCartsModel, NoParams> {
  final OrdersRepo ordersRepo;

  FetchRestaurantCartUseCase({required this.ordersRepo});

  @override
  DataResponse<FetchMerchantCartsModel> call(NoParams params) {
    return ordersRepo.fetchRestaurantCarts();
  }
}
