import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/orders_api_models.dart';
import '../repository/orders_repo.dart';
import 'update_cart_item_quantity_use_case.dart';

@lazySingleton
class UpdateStoreCartItemQuantityUseCase
    implements UseCase<OrdersActionResultModel, UpdateCartItemQuantityParams> {
  final OrdersRepo ordersRepo;

  UpdateStoreCartItemQuantityUseCase({required this.ordersRepo});

  @override
  DataResponse<OrdersActionResultModel> call(UpdateCartItemQuantityParams params) {
    return ordersRepo.updateStoreCartItemQuantity(params);
  }
}
