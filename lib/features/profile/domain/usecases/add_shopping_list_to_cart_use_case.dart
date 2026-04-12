import 'package:common_package/common_package.dart';
import 'package:injectable/injectable.dart';

import '../../../orders/data/models/orders_api_models.dart';
import '../repository/shopping_lists_repo.dart';

@lazySingleton
class AddShoppingListToCartUseCase
    implements UseCase<FetchRestaurantCartModel, AddShoppingListToCartParams> {
  final ShoppingListsRepo shoppingListsRepo;

  AddShoppingListToCartUseCase({required this.shoppingListsRepo});

  @override
  DataResponse<FetchRestaurantCartModel> call(AddShoppingListToCartParams params) {
    return shoppingListsRepo.addShoppingListToCart(params);
  }
}

class AddShoppingListToCartParams with Params {
  final int shoppingListId;
  final int storeId;

  AddShoppingListToCartParams({required this.shoppingListId, required this.storeId});

  @override
  BodyMap getBody() => <String, dynamic>{'storeId': storeId};
}
