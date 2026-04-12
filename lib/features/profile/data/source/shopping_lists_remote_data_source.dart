import 'package:common_package/common_package.dart';
import 'package:injectable/injectable.dart';

import '../../../orders/data/models/orders_api_models.dart';
import '../../domain/usecases/add_shopping_list_item_use_case.dart';
import '../../domain/usecases/add_shopping_list_to_cart_use_case.dart';
import '../../domain/usecases/create_shopping_list_use_case.dart';
import '../../domain/usecases/delete_shopping_list_item_use_case.dart';
import '../../domain/usecases/delete_shopping_list_use_case.dart';
import '../../domain/usecases/fetch_shopping_list_detail_use_case.dart';
import '../../domain/usecases/fetch_shopping_lists_use_case.dart';
import '../../domain/usecases/update_shopping_list_item_use_case.dart';
import '../../domain/usecases/update_shopping_list_use_case.dart';
import '../models/profile_api_models.dart';
import '../models/shopping_lists_api_models.dart';

@lazySingleton
class ShoppingListsRemoteDataSource with HandlingApiManager {
  final DioNetwork dioNetwork;

  ShoppingListsRemoteDataSource({required this.dioNetwork});

  Future<FetchShoppingListsModel> fetchShoppingLists(
    FetchShoppingListsParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/supermarket/shopping-lists',
        params: params.getParams(),
        data: params.getBody().isEmpty ? null : params.getBody(),
      ),
      jsonConvert: fetchShoppingListsModelFromJson,
    );
  }

  Future<ShoppingListDetailResponseModel> createShoppingList(
    CreateShoppingListParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint: '/api/v1/user/supermarket/shopping-lists',
        data: params.getBody(),
      ),
      jsonConvert: shoppingListDetailResponseModelFromJson,
    );
  }

  Future<ShoppingListDetailResponseModel> fetchShoppingListDetail(
    FetchShoppingListDetailParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/supermarket/shopping-lists/${params.shoppingListId}',
      ),
      jsonConvert: shoppingListDetailResponseModelFromJson,
    );
  }

  Future<ShoppingListDetailResponseModel> updateShoppingList(
    UpdateShoppingListParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.patchData(
        endPoint: '/api/v1/user/supermarket/shopping-lists/${params.shoppingListId}',
        data: params.getBody(),
      ),
      jsonConvert: shoppingListDetailResponseModelFromJson,
    );
  }

  Future<ActionResultModel> deleteShoppingList(DeleteShoppingListParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.deleteData(
        endPoint: '/api/v1/user/supermarket/shopping-lists/${params.shoppingListId}',
      ),
      jsonConvert: actionResultModelFromJson,
    );
  }

  Future<ShoppingListDetailResponseModel> addShoppingListItem(
    AddShoppingListItemParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint: '/api/v1/user/supermarket/shopping-lists/${params.shoppingListId}/items',
        data: params.getBody(),
      ),
      jsonConvert: shoppingListDetailResponseModelFromJson,
    );
  }

  Future<ShoppingListDetailResponseModel> updateShoppingListItem(
    UpdateShoppingListItemParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.patchData(
        endPoint: '/api/v1/user/supermarket/shopping-lists/${params.shoppingListId}/items/${params.itemId}',
        data: params.getBody(),
      ),
      jsonConvert: shoppingListDetailResponseModelFromJson,
    );
  }

  Future<ActionResultModel> deleteShoppingListItem(
    DeleteShoppingListItemParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.deleteData(
        endPoint: '/api/v1/user/supermarket/shopping-lists/${params.shoppingListId}/items/${params.itemId}',
      ),
      jsonConvert: actionResultModelFromJson,
    );
  }

  Future<FetchRestaurantCartModel> addShoppingListToCart(
    AddShoppingListToCartParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint: '/api/v1/user/supermarket/shopping-lists/${params.shoppingListId}/add-to-cart',
        data: params.getBody(),
      ),
      jsonConvert: addShoppingListToCartModelFromJson,
    );
  }
}
