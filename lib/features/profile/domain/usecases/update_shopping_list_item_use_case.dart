import 'package:common_package/common_package.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/shopping_lists_api_models.dart';
import '../repository/shopping_lists_repo.dart';

@lazySingleton
class UpdateShoppingListItemUseCase
    implements
        UseCase<ShoppingListDetailResponseModel, UpdateShoppingListItemParams> {
  final ShoppingListsRepo shoppingListsRepo;

  UpdateShoppingListItemUseCase({required this.shoppingListsRepo});

  @override
  DataResponse<ShoppingListDetailResponseModel> call(
    UpdateShoppingListItemParams params,
  ) {
    return shoppingListsRepo.updateShoppingListItem(params);
  }
}

class UpdateShoppingListItemParams with Params {
  final int shoppingListId;
  final int itemId;
  final num? quantity;
  final int? sortOrder;
  final bool? isIncluded;

  UpdateShoppingListItemParams({
    required this.shoppingListId,
    required this.itemId,
    this.quantity,
    this.sortOrder,
    this.isIncluded,
  });

  @override
  BodyMap getBody() {
    return <String, dynamic>{
      if (quantity != null) 'quantity': quantity,
      if (sortOrder != null) 'sortOrder': sortOrder,
      if (isIncluded != null) 'isIncluded': isIncluded,
    };
  }
}
