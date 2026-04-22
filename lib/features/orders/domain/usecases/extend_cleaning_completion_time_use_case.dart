import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/cleaning_orders_api_models.dart';
import '../repository/orders_repo.dart';

@lazySingleton
class ExtendCleaningCompletionTimeUseCase
    implements
        UseCase<
          FetchCleaningOrderDetailsModel,
          ExtendCleaningCompletionTimeParams
        > {
  final OrdersRepo ordersRepo;

  ExtendCleaningCompletionTimeUseCase({required this.ordersRepo});

  @override
  DataResponse<FetchCleaningOrderDetailsModel> call(
    ExtendCleaningCompletionTimeParams params,
  ) {
    return ordersRepo.extendCleaningCompletionTime(params);
  }
}

class ExtendCleaningCompletionTimeParams with Params {
  final int orderId;
  final int? additionalMinutes;

  ExtendCleaningCompletionTimeParams({
    required this.orderId,
    this.additionalMinutes,
  });

  @override
  BodyMap getBody() {
    if (additionalMinutes == null) {
      return <String, dynamic>{};
    }
    return {'additionalMinutes': additionalMinutes};
  }
}
