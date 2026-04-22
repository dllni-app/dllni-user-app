import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/cleaning_orders_api_models.dart';
import '../repository/orders_repo.dart';

@lazySingleton
class RejectCleaningCompletionUseCase
    implements
        UseCase<
          FetchCleaningOrderDetailsModel,
          RejectCleaningCompletionParams
        > {
  final OrdersRepo ordersRepo;

  RejectCleaningCompletionUseCase({required this.ordersRepo});

  @override
  DataResponse<FetchCleaningOrderDetailsModel> call(
    RejectCleaningCompletionParams params,
  ) {
    return ordersRepo.rejectCleaningCompletion(params);
  }
}

class RejectCleaningCompletionParams with Params {
  final int orderId;
  final String? reason;

  RejectCleaningCompletionParams({
    required this.orderId,
    this.reason,
  });

  @override
  BodyMap getBody() {
    final r = reason?.trim();
    if (r == null || r.isEmpty) {
      return <String, dynamic>{};
    }
    return {'reason': r};
  }
}
