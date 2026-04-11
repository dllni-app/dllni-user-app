import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/orders_api_models.dart';
import '../repository/orders_repo.dart';

@lazySingleton
class FetchRestaurantCartUseCase
    implements UseCase<FetchRestaurantCartModel, NoParams> {
  final OrdersRepo ordersRepo;

  FetchRestaurantCartUseCase({required this.ordersRepo});

  @override
  DataResponse<FetchRestaurantCartModel> call(NoParams params) {
    return ordersRepo.fetchRestaurantCart();
  }
}
