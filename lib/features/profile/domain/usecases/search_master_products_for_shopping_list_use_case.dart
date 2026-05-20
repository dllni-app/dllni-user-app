import 'package:common_package/common_package.dart';

import '../../data/models/search_master_products_for_shopping_list_model.dart';
import '../repository/shopping_lists_repo.dart';

class SearchMasterProductsForShoppingListUseCase
    implements
        UseCase<
          SearchMasterProductsForShoppingListModel,
          SearchMasterProductsForShoppingListParams
        > {
  final ShoppingListsRepo shoppingListsRepo;

  SearchMasterProductsForShoppingListUseCase({required this.shoppingListsRepo});

  @override
  DataResponse<SearchMasterProductsForShoppingListModel> call(
    SearchMasterProductsForShoppingListParams params,
  ) {
    return shoppingListsRepo.searchMasterProducts(params);
  }
}

class SearchMasterProductsForShoppingListParams with Params {
  final String index;
  final int? page;
  final int? perPage;

  SearchMasterProductsForShoppingListParams({
    required this.index,
    this.page,
    this.perPage,
  });

  @override
  QueryParams getParams() {
    return <String, dynamic>{
      'index': index,
      if (page != null) 'page': page,
      if (perPage != null) 'perPage': perPage,
    };
  }
}
