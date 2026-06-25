import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/orders_api_models.dart';
import '../repository/orders_repo.dart';

@lazySingleton
class UpdateCartItemQuantityUseCase
    implements UseCase<FetchRestaurantCartModel, UpdateCartItemQuantityParams> {
  final OrdersRepo ordersRepo;

  UpdateCartItemQuantityUseCase({required this.ordersRepo});

  @override
  DataResponse<FetchRestaurantCartModel> call(
    UpdateCartItemQuantityParams params,
  ) {
    return ordersRepo.updateCartItemQuantity(params);
  }
}

class UpdateCartItemQuantityParams with Params {
  final int cartId;
  final int itemId;
  final int quantity;

  UpdateCartItemQuantityParams({
    required this.cartId,
    required this.itemId,
    required this.quantity,
  });

  @override
  BodyMap getBody() {
    return <String, dynamic>{'quantity': quantity};
  }
}
