import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/delivery_order_models.dart';
import '../repository/delivery_repo.dart';

@lazySingleton
class FetchDeliveryOrdersUseCase
    implements UseCase<FetchDeliveryOrdersModel, FetchDeliveryOrdersParams> {
  FetchDeliveryOrdersUseCase({required this.deliveryRepo});

  final DeliveryRepo deliveryRepo;

  @override
  DataResponse<FetchDeliveryOrdersModel> call(FetchDeliveryOrdersParams params) {
    return deliveryRepo.fetchDeliveryOrders(params);
  }
}

class FetchDeliveryOrdersParams with Params {
  FetchDeliveryOrdersParams({this.page = 1, this.perPage = 20});

  final int page;
  final int perPage;

  @override
  Map<String, dynamic> getParams() => {
        'page': page,
        'perPage': perPage,
      };
}
