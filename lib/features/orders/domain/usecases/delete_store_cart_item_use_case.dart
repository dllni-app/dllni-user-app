import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/orders_api_models.dart';
import '../repository/orders_repo.dart';
import 'delete_cart_item_use_case.dart';

@lazySingleton
class DeleteStoreCartItemUseCase
    implements UseCase<OrdersActionResultModel, DeleteCartItemParams> {
  final OrdersRepo ordersRepo;

  DeleteStoreCartItemUseCase({required this.ordersRepo});

  @override
  DataResponse<OrdersActionResultModel> call(DeleteCartItemParams params) {
    return ordersRepo.deleteStoreCartItem(params);
  }
}
