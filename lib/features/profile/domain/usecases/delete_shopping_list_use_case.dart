import 'package:common_package/common_package.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/profile_api_models.dart';
import '../repository/shopping_lists_repo.dart';

@lazySingleton
class DeleteShoppingListUseCase
    implements UseCase<ActionResultModel, DeleteShoppingListParams> {
  final ShoppingListsRepo shoppingListsRepo;

  DeleteShoppingListUseCase({required this.shoppingListsRepo});

  @override
  DataResponse<ActionResultModel> call(DeleteShoppingListParams params) {
    return shoppingListsRepo.deleteShoppingList(params);
  }
}

class DeleteShoppingListParams with Params {
  final int shoppingListId;

  DeleteShoppingListParams({required this.shoppingListId});
}
