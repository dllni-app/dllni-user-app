import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/add_supermarket_cart_item_model.dart';
import '../repository/sm_stores_repo.dart';

@lazySingleton
class AddSupermarketCartItemUseCase
    implements
        UseCase<AddSupermarketCartItemModel, AddSupermarketCartItemParams> {
  final SmStoresRepo smStores;

  AddSupermarketCartItemUseCase({required this.smStores});

  @override
  DataResponse<AddSupermarketCartItemModel> call(
    AddSupermarketCartItemParams params,
  ) {
    return smStores.addSupermarketCartItem(params);
  }
}

class AddSupermarketCartItemParams with Params {
  final int productId;
  final int quantity;

  AddSupermarketCartItemParams({
    required this.productId,
    required this.quantity,
  });

  @override
  BodyMap getBody() => {
        'productId': productId,
        'quantity': quantity,
      };
}
