import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/orders_api_models.dart';
import '../repository/orders_repo.dart';

@lazySingleton
class DeleteCartItemUseCase
    implements UseCase<OrdersActionResultModel, DeleteCartItemParams> {
  final OrdersRepo ordersRepo;

  DeleteCartItemUseCase({required this.ordersRepo});

  @override
  DataResponse<OrdersActionResultModel> call(DeleteCartItemParams params) {
    return ordersRepo.deleteCartItem(params);
  }
}

class DeleteCartItemParams with Params {
  final int itemId;

  DeleteCartItemParams({required this.itemId});
}
