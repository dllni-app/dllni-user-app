import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

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
  /// When null, no status filter is sent (used by global verification polling).
  final String? status;
  final int perPage;
  final int page;

  FetchCleaningOrdersParams({
    this.status,
    this.perPage = 10,
    this.page = 1,
  });

  @override
  QueryParams getParams() {
    final params = <String, dynamic>{
      'perPage': perPage,
      'page': page,
    };
    final filterStatus = status?.trim();
    if (filterStatus != null && filterStatus.isNotEmpty) {
      params['filter[status]'] = filterStatus;
    }
    return params;
  }
}
