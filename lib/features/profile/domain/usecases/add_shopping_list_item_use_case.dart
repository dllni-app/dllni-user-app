import 'package:common_package/common_package.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/shopping_lists_api_models.dart';
import '../repository/shopping_lists_repo.dart';

@lazySingleton
class AddShoppingListItemUseCase
    implements UseCase<ShoppingListDetailResponseModel, AddShoppingListItemParams> {
  final ShoppingListsRepo shoppingListsRepo;

  AddShoppingListItemUseCase({required this.shoppingListsRepo});

  @override
  DataResponse<ShoppingListDetailResponseModel> call(AddShoppingListItemParams params) {
    return shoppingListsRepo.addShoppingListItem(params);
  }
}

class AddShoppingListItemParams with Params {
  final int shoppingListId;
  final int masterProductId;
  final num quantity;
  final String? unit;
  final int? sortOrder;
  final bool? isIncluded;

  AddShoppingListItemParams({
    required this.shoppingListId,
    required this.masterProductId,
    this.quantity = 1,
    this.unit,
    this.sortOrder,
    this.isIncluded,
  });

  @override
  BodyMap getBody() {
    return <String, dynamic>{
      'masterProductId': masterProductId,
      'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (sortOrder != null) 'sortOrder': sortOrder,
      if (isIncluded != null) 'isIncluded': isIncluded,
    };
  }
}
