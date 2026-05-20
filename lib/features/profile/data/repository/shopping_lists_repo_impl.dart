import 'package:common_package/common_package.dart';
import 'package:injectable/injectable.dart';

import '../../../orders/data/models/orders_api_models.dart';
import '../../domain/repository/shopping_lists_repo.dart';
import '../../domain/usecases/add_shopping_list_item_use_case.dart';
import '../../domain/usecases/add_shopping_list_to_cart_use_case.dart';
import '../../domain/usecases/create_shopping_list_use_case.dart';
import '../../domain/usecases/delete_shopping_list_item_use_case.dart';
import '../../domain/usecases/delete_shopping_list_use_case.dart';
import '../../domain/usecases/fetch_shopping_list_detail_use_case.dart';
import '../../domain/usecases/fetch_shopping_lists_use_case.dart';
import '../../domain/usecases/update_shopping_list_item_use_case.dart';
import '../../domain/usecases/update_shopping_list_use_case.dart';
import '../../domain/usecases/search_master_products_for_shopping_list_use_case.dart';
import '../models/profile_api_models.dart';
import '../models/shopping_lists_api_models.dart';
import '../models/search_master_products_for_shopping_list_model.dart';
import '../source/shopping_lists_remote_data_source.dart';

@LazySingleton(as: ShoppingListsRepo)
class ShoppingListsRepoImpl
    with HandlingException
    implements ShoppingListsRepo {
  final ShoppingListsRemoteDataSource shoppingListsRemoteDataSource;

  ShoppingListsRepoImpl({required this.shoppingListsRemoteDataSource});

  @override
  DataResponse<FetchShoppingListsModel> fetchShoppingLists(
    FetchShoppingListsParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => shoppingListsRemoteDataSource.fetchShoppingLists(params),
    );
  }

  @override
  DataResponse<ShoppingListDetailResponseModel> createShoppingList(
    CreateShoppingListParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => shoppingListsRemoteDataSource.createShoppingList(params),
    );
  }

  @override
  DataResponse<ShoppingListDetailResponseModel> fetchShoppingListDetail(
    FetchShoppingListDetailParams params,
  ) {
    return wrapHandlingException(
      tryCall: () =>
          shoppingListsRemoteDataSource.fetchShoppingListDetail(params),
    );
  }

  @override
  DataResponse<ShoppingListDetailResponseModel> updateShoppingList(
    UpdateShoppingListParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => shoppingListsRemoteDataSource.updateShoppingList(params),
    );
  }

  @override
  DataResponse<ActionResultModel> deleteShoppingList(
    DeleteShoppingListParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => shoppingListsRemoteDataSource.deleteShoppingList(params),
    );
  }

  @override
  DataResponse<ShoppingListDetailResponseModel> addShoppingListItem(
    AddShoppingListItemParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => shoppingListsRemoteDataSource.addShoppingListItem(params),
    );
  }

  @override
  DataResponse<ShoppingListDetailResponseModel> updateShoppingListItem(
    UpdateShoppingListItemParams params,
  ) {
    return wrapHandlingException(
      tryCall: () =>
          shoppingListsRemoteDataSource.updateShoppingListItem(params),
    );
  }

  @override
  DataResponse<ActionResultModel> deleteShoppingListItem(
    DeleteShoppingListItemParams params,
  ) {
    return wrapHandlingException(
      tryCall: () =>
          shoppingListsRemoteDataSource.deleteShoppingListItem(params),
    );
  }

  @override
  DataResponse<FetchRestaurantCartModel> addShoppingListToCart(
    AddShoppingListToCartParams params,
  ) {
    return wrapHandlingException(
      tryCall: () =>
          shoppingListsRemoteDataSource.addShoppingListToCart(params),
    );
  }

  @override
  DataResponse<SearchMasterProductsForShoppingListModel> searchMasterProducts(
    SearchMasterProductsForShoppingListParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => shoppingListsRemoteDataSource.searchMasterProducts(params),
    );
  }
}
