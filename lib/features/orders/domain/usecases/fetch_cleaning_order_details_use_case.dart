import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/cleaning_orders_api_models.dart';
import '../repository/orders_repo.dart';

@lazySingleton
class FetchCleaningOrderDetailsUseCase
    implements
        UseCase<
          FetchCleaningOrderDetailsModel,
          FetchCleaningOrderDetailsParams
        > {
  final OrdersRepo ordersRepo;

  FetchCleaningOrderDetailsUseCase({required this.ordersRepo});

  @override
  DataResponse<FetchCleaningOrderDetailsModel> call(
    FetchCleaningOrderDetailsParams params,
  ) {
    return ordersRepo.fetchCleaningOrderDetails(params);
  }
}

class FetchCleaningOrderDetailsParams with Params {
  final int orderId;

  FetchCleaningOrderDetailsParams({required this.orderId});
}
