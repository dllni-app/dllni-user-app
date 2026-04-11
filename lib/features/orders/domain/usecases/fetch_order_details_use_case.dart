import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/orders_api_models.dart';
import '../repository/orders_repo.dart';

@lazySingleton
class FetchOrderDetailsUseCase
    implements UseCase<FetchOrderDetailsModel, FetchOrderDetailsParams> {
  final OrdersRepo ordersRepo;

  FetchOrderDetailsUseCase({required this.ordersRepo});

  @override
  DataResponse<FetchOrderDetailsModel> call(FetchOrderDetailsParams params) {
    return ordersRepo.fetchOrderDetails(params);
  }
}

class FetchOrderDetailsParams with Params {
  final String section;
  final int orderId;

  FetchOrderDetailsParams({required this.section, required this.orderId});
}
