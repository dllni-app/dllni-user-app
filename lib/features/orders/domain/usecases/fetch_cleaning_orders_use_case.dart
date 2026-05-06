import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/cleaning_booking_status.dart';
import '../../data/models/cleaning_orders_api_models.dart';
import '../repository/orders_repo.dart';

@lazySingleton
class FetchCleaningOrdersUseCase
    implements UseCase<FetchCleaningOrdersModel, FetchCleaningOrdersParams> {
  final OrdersRepo ordersRepo;

  FetchCleaningOrdersUseCase({required this.ordersRepo});

  @override
  DataResponse<FetchCleaningOrdersModel> call(
    FetchCleaningOrdersParams params,
  ) {
    return ordersRepo.fetchCleaningOrders(params);
  }
}

class FetchCleaningOrdersParams with Params {
  final String status;
  final int perPage;
  final int page;

  FetchCleaningOrdersParams({
    this.status = CleaningBookingStatus.pending,
    this.perPage = 10,
    this.page = 1,
  });

  @override
  QueryParams getParams() => {
    'filter[status]': status,
    'perPage': perPage,
    'page': page,
  };
}
