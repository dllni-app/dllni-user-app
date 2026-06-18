import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/delivery_order_models.dart';
import '../repository/delivery_repo.dart';

@lazySingleton
class FetchDeliveryOrderDetailsUseCase
    implements
        UseCase<FetchDeliveryOrderDetailsModel, FetchDeliveryOrderDetailsParams> {
  FetchDeliveryOrderDetailsUseCase({required this.deliveryRepo});

  final DeliveryRepo deliveryRepo;

  @override
  DataResponse<FetchDeliveryOrderDetailsModel> call(
    FetchDeliveryOrderDetailsParams params,
  ) {
    return deliveryRepo.fetchDeliveryOrderDetails(params);
  }
}

class FetchDeliveryOrderDetailsParams with Params {
  FetchDeliveryOrderDetailsParams({required this.orderId});

  final int orderId;
}
