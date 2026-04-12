import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/cleaning_order_cancel_api_models.dart';
import '../repository/orders_repo.dart';

@lazySingleton
class CancelCleaningOrderUseCase
    implements UseCase<CleaningCancelResultModel, CancelCleaningOrderParams> {
  final OrdersRepo ordersRepo;

  CancelCleaningOrderUseCase({required this.ordersRepo});

  @override
  DataResponse<CleaningCancelResultModel> call(CancelCleaningOrderParams params) {
    return ordersRepo.cancelCleaningOrder(params);
  }
}

class CancelCleaningOrderParams with Params {
  final int cleaningOrderId;
  final String reason;

  CancelCleaningOrderParams({
    required this.cleaningOrderId,
    required this.reason,
  });

  @override
  BodyMap getBody() => {
        'reason': reason,
      };
}
