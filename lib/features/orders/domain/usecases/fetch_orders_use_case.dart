export 'fetch_cleaning_orders_use_case.dart';

import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/orders_api_models.dart';
import '../repository/orders_repo.dart';

@lazySingleton
class FetchOrdersUseCase
    implements UseCase<FetchOrdersModel, FetchOrdersParams> {
  final OrdersRepo ordersRepo;

  FetchOrdersUseCase({required this.ordersRepo});

  @override
  DataResponse<FetchOrdersModel> call(FetchOrdersParams params) {
    return ordersRepo.fetchOrders(params);
  }
}

class FetchOrdersParams with Params {
  final String section;
  final int perPage;
  final int page;

  FetchOrdersParams({
    required this.section,
    this.perPage = 10,
    this.page = 1,
  });

  @override
  QueryParams getParams() => {
        'section': section,
        'perPage': perPage,
        'page': page,
      };
}
