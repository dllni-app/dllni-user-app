import 'package:common_package/common_package.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/shopping_lists_api_models.dart';
import '../repository/shopping_lists_repo.dart';

@lazySingleton
class FetchShoppingListsUseCase
    implements UseCase<FetchShoppingListsModel, FetchShoppingListsParams> {
  final ShoppingListsRepo shoppingListsRepo;

  FetchShoppingListsUseCase({required this.shoppingListsRepo});

  @override
  DataResponse<FetchShoppingListsModel> call(FetchShoppingListsParams params) {
    return shoppingListsRepo.fetchShoppingLists(params);
  }
}

class FetchShoppingListsParams with Params {}
