import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/orders_api_models.dart';
import '../repository/orders_repo.dart';

@lazySingleton
class FetchRestaurantOrderTrackingUseCase
    implements UseCase<FetchRestaurantOrderTrackingModel, FetchRestaurantOrderTrackingParams> {
  final OrdersRepo ordersRepo;

  FetchRestaurantOrderTrackingUseCase({required this.ordersRepo});

  @override
  DataResponse<FetchRestaurantOrderTrackingModel> call(FetchRestaurantOrderTrackingParams params) {
    return ordersRepo.fetchRestaurantOrderTracking(params);
  }
}

class FetchRestaurantOrderTrackingParams with Params {
  FetchRestaurantOrderTrackingParams({required this.orderId});

  final int orderId;
}
