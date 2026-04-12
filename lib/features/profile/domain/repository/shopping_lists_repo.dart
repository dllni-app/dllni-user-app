import 'package:common_package/common_package.dart';

import '../../../orders/data/models/orders_api_models.dart';
import '../../data/models/profile_api_models.dart';
import '../../data/models/shopping_lists_api_models.dart';
import '../usecases/add_shopping_list_item_use_case.dart';
import '../usecases/add_shopping_list_to_cart_use_case.dart';
import '../usecases/create_shopping_list_use_case.dart';
import '../usecases/delete_shopping_list_item_use_case.dart';
import '../usecases/delete_shopping_list_use_case.dart';
import '../usecases/fetch_shopping_list_detail_use_case.dart';
import '../usecases/fetch_shopping_lists_use_case.dart';
import '../usecases/update_shopping_list_item_use_case.dart';
import '../usecases/update_shopping_list_use_case.dart';

abstract class ShoppingListsRepo {
  DataResponse<FetchShoppingListsModel> fetchShoppingLists(
    FetchShoppingListsParams params,
  );

  DataResponse<ShoppingListDetailResponseModel> createShoppingList(
    CreateShoppingListParams params,
  );

  DataResponse<ShoppingListDetailResponseModel> fetchShoppingListDetail(
    FetchShoppingListDetailParams params,
  );

  DataResponse<ShoppingListDetailResponseModel> updateShoppingList(
    UpdateShoppingListParams params,
  );

  DataResponse<ActionResultModel> deleteShoppingList(
    DeleteShoppingListParams params,
  );

  DataResponse<ShoppingListDetailResponseModel> addShoppingListItem(
    AddShoppingListItemParams params,
  );

  DataResponse<ShoppingListDetailResponseModel> updateShoppingListItem(
    UpdateShoppingListItemParams params,
  );

  DataResponse<ActionResultModel> deleteShoppingListItem(
    DeleteShoppingListItemParams params,
  );

  DataResponse<FetchRestaurantCartModel> addShoppingListToCart(
    AddShoppingListToCartParams params,
  );
}
