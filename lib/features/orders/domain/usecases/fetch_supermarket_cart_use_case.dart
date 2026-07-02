import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/typedef.dart';

import '../repository/orders_repo.dart';
import '../../data/models/fetch_supermarket_cart_model.dart';

@lazySingleton
class FetchSupermarketCartUseCase implements UseCase<FetchSupermarketCartModel, FetchSupermarketCartParams> {

  final OrdersRepo orders;

  FetchSupermarketCartUseCase({required this.orders});

  @override
  DataResponse<FetchSupermarketCartModel> call(FetchSupermarketCartParams params) {
    return orders.fetchSupermarketCart(params);
  }
}

class FetchSupermarketCartParams with Params{}
