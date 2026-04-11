import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/orders_api_models.dart';
import '../repository/orders_repo.dart';

@lazySingleton
class UpdateCartItemQuantityUseCase
    implements UseCase<OrdersActionResultModel, UpdateCartItemQuantityParams> {
  final OrdersRepo ordersRepo;

  UpdateCartItemQuantityUseCase({required this.ordersRepo});

  @override
  DataResponse<OrdersActionResultModel> call(UpdateCartItemQuantityParams params) {
    return ordersRepo.updateCartItemQuantity(params);
  }
}

class UpdateCartItemQuantityParams with Params {
  final int itemId;
  final int quantity;

  UpdateCartItemQuantityParams({required this.itemId, required this.quantity});

  @override
  BodyMap getBody() => {
        'quantity': quantity,
      };
}
