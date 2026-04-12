import 'package:common_package/common_package.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/shopping_lists_api_models.dart';
import '../repository/shopping_lists_repo.dart';

@lazySingleton
class UpdateShoppingListUseCase
    implements UseCase<ShoppingListDetailResponseModel, UpdateShoppingListParams> {
  final ShoppingListsRepo shoppingListsRepo;

  UpdateShoppingListUseCase({required this.shoppingListsRepo});

  @override
  DataResponse<ShoppingListDetailResponseModel> call(UpdateShoppingListParams params) {
    return shoppingListsRepo.updateShoppingList(params);
  }
}

class UpdateShoppingListParams with Params {
  final int shoppingListId;
  final String? name;
  final String? description;
  final bool? isActive;

  UpdateShoppingListParams({
    required this.shoppingListId,
    this.name,
    this.description,
    this.isActive,
  });

  @override
  BodyMap getBody() {
    return <String, dynamic>{
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (isActive != null) 'isActive': isActive,
    };
  }
}
