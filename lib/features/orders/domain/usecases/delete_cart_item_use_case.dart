import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/orders_api_models.dart';
import '../repository/orders_repo.dart';

@lazySingleton
class DeleteCartItemUseCase
    implements UseCase<FetchRestaurantCartModel, DeleteCartItemParams> {
  final OrdersRepo ordersRepo;

  DeleteCartItemUseCase({required this.ordersRepo});

  @override
  DataResponse<FetchRestaurantCartModel> call(DeleteCartItemParams params) {
    return ordersRepo.deleteCartItem(params);
  }
}

class DeleteCartItemParams with Params {
  final int cartId;
  final int itemId;

  DeleteCartItemParams({required this.cartId, required this.itemId});
}
