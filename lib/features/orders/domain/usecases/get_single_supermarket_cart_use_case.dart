import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/typedef.dart';

import '../../data/models/fetch_supermarket_cart_model.dart';
import '../repository/orders_repo.dart';

@lazySingleton
class GetSingleSupermarketCartUseCase implements UseCase<
          FetchSupermarketCartModelDataItem, GetSingleSupermarketCartParams> {

  final OrdersRepo orders;

  GetSingleSupermarketCartUseCase({required this.orders});

  @override
  DataResponse<FetchSupermarketCartModelDataItem> call(GetSingleSupermarketCartParams params) {
    return orders.getSingleSupermarketCart(params);
  }
}

class GetSingleSupermarketCartParams with Params{
  final int cartId;
  GetSingleSupermarketCartParams({required this.cartId});
}
