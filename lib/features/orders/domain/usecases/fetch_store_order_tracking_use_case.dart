import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/orders_api_models.dart';
import '../repository/orders_repo.dart';
import 'fetch_restaurant_order_tracking_use_case.dart';

@lazySingleton
class FetchStoreOrderTrackingUseCase
    implements UseCase<FetchRestaurantOrderTrackingModel, FetchRestaurantOrderTrackingParams> {
  final OrdersRepo ordersRepo;

  FetchStoreOrderTrackingUseCase({required this.ordersRepo});

  @override
  DataResponse<FetchRestaurantOrderTrackingModel> call(
    FetchRestaurantOrderTrackingParams params,
  ) {
    return ordersRepo.fetchStoreOrderTracking(params);
  }
}
