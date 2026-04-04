import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/rs_orders_api_models.dart';
import '../repository/rs_orders_repo.dart';

@lazySingleton
class ShowOrderUseCase
    implements UseCase<FetchOrderDetailsModel, ShowOrderParams> {
  final RsOrdersRepo rsOrdersRepo;

  ShowOrderUseCase({required this.rsOrdersRepo});

  @override
  DataResponse<FetchOrderDetailsModel> call(ShowOrderParams params) {
    return rsOrdersRepo.showOrder(orderId: params.orderId);
  }
}

class ShowOrderParams with Params {
  final int orderId;

  ShowOrderParams({required this.orderId});

  @override
  QueryParams getParams() => {'orderId': orderId};
}
