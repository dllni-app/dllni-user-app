import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/typedef.dart';

import '../repository/orders_repo.dart';
import '../../data/models/remove_supermarket_cart_model.dart';

@lazySingleton
class RemoveSupermarketCartUseCase
    implements
        UseCase<RemoveSupermarketCartModel, RemoveSupermarketCartParams> {
  final OrdersRepo orders;

  RemoveSupermarketCartUseCase({required this.orders});

  @override
  DataResponse<RemoveSupermarketCartModel> call(
    RemoveSupermarketCartParams params,
  ) {
    return orders.removeSupermarketCart(params);
  }
}

class RemoveSupermarketCartParams with Params {
  final int id;

  RemoveSupermarketCartParams({required this.id});

}
