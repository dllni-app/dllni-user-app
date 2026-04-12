import 'package:common_package/common_package.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/profile_api_models.dart';
import '../repository/shopping_lists_repo.dart';

@lazySingleton
class DeleteShoppingListItemUseCase
    implements UseCase<ActionResultModel, DeleteShoppingListItemParams> {
  final ShoppingListsRepo shoppingListsRepo;

  DeleteShoppingListItemUseCase({required this.shoppingListsRepo});

  @override
  DataResponse<ActionResultModel> call(DeleteShoppingListItemParams params) {
    return shoppingListsRepo.deleteShoppingListItem(params);
  }
}

class DeleteShoppingListItemParams with Params {
  final int shoppingListId;
  final int itemId;

  DeleteShoppingListItemParams({
    required this.shoppingListId,
    required this.itemId,
  });
}
