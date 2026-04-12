import 'package:common_package/common_package.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/shopping_lists_api_models.dart';
import '../repository/shopping_lists_repo.dart';

@lazySingleton
class FetchShoppingListDetailUseCase
    implements
        UseCase<ShoppingListDetailResponseModel, FetchShoppingListDetailParams> {
  final ShoppingListsRepo shoppingListsRepo;

  FetchShoppingListDetailUseCase({required this.shoppingListsRepo});

  @override
  DataResponse<ShoppingListDetailResponseModel> call(
    FetchShoppingListDetailParams params,
  ) {
    return shoppingListsRepo.fetchShoppingListDetail(params);
  }
}

class FetchShoppingListDetailParams with Params {
  final int shoppingListId;

  FetchShoppingListDetailParams({required this.shoppingListId});
}
