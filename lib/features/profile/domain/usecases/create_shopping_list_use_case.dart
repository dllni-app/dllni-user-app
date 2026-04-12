import 'package:common_package/common_package.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/shopping_lists_api_models.dart';
import '../repository/shopping_lists_repo.dart';

@lazySingleton
class CreateShoppingListUseCase
    implements UseCase<ShoppingListDetailResponseModel, CreateShoppingListParams> {
  final ShoppingListsRepo shoppingListsRepo;

  CreateShoppingListUseCase({required this.shoppingListsRepo});

  @override
  DataResponse<ShoppingListDetailResponseModel> call(CreateShoppingListParams params) {
    return shoppingListsRepo.createShoppingList(params);
  }
}

class CreateShoppingListParams with Params {
  final String name;
  final String? description;
  final bool? isActive;

  CreateShoppingListParams({required this.name, this.description, this.isActive});

  @override
  BodyMap getBody() {
    return <String, dynamic>{
      'name': name,
      if (description != null) 'description': description,
      if (isActive != null) 'isActive': isActive,
    };
  }
}
