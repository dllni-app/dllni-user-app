import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/cleaning_orders_api_models.dart';
import '../repository/orders_repo.dart';

@lazySingleton
class ConfirmCleaningCompletionUseCase
    implements
        UseCase<
          FetchCleaningOrderDetailsModel,
          ConfirmCleaningCompletionParams
        > {
  final OrdersRepo ordersRepo;

  ConfirmCleaningCompletionUseCase({required this.ordersRepo});

  @override
  DataResponse<FetchCleaningOrderDetailsModel> call(
    ConfirmCleaningCompletionParams params,
  ) {
    return ordersRepo.confirmCleaningCompletion(params);
  }
}

class ConfirmCleaningCompletionParams with Params {
  final int orderId;

  ConfirmCleaningCompletionParams({required this.orderId});

  @override
  BodyMap getBody() => <String, dynamic>{};
}
