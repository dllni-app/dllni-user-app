import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/rs_orders_api_models.dart';
import '../repository/rs_orders_repo.dart';

@lazySingleton
class ListOrdersUseCase
    implements UseCase<FetchOrdersListModel, ListOrdersParams> {
  final RsOrdersRepo rsOrdersRepo;

  ListOrdersUseCase({required this.rsOrdersRepo});

  @override
  DataResponse<FetchOrdersListModel> call(ListOrdersParams params) {
    return rsOrdersRepo.listOrders(page: params.page, perPage: params.perPage);
  }
}

class ListOrdersParams with Params {
  final int page;
  final int perPage;

  ListOrdersParams({this.page = 1, this.perPage = 20});

  @override
  QueryParams getParams() => {'page': page, 'perPage': perPage};
}
