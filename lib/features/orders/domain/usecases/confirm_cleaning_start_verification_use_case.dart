import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/cleaning_orders_api_models.dart';
import '../repository/orders_repo.dart';

@lazySingleton
class ConfirmCleaningStartVerificationUseCase
    implements
        UseCase<
          FetchCleaningOrderDetailsModel,
          ConfirmCleaningStartVerificationParams
        > {
  final OrdersRepo ordersRepo;

  ConfirmCleaningStartVerificationUseCase({required this.ordersRepo});

  @override
  DataResponse<FetchCleaningOrderDetailsModel> call(
    ConfirmCleaningStartVerificationParams params,
  ) {
    return ordersRepo.confirmCleaningStartVerification(params);
  }
}

class ConfirmCleaningStartVerificationParams with Params {
  final int orderId;
  final String code;

  ConfirmCleaningStartVerificationParams({
    required this.orderId,
    required this.code,
  });

  @override
  BodyMap getBody() => {'code': code};
}
