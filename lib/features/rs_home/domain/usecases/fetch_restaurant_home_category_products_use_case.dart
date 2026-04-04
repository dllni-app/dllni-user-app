import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/fetch_restaurant_home_category_products_model.dart';
import '../repository/rs_home_repo.dart';

@lazySingleton
class FetchRestaurantHomeCategoryProductsUseCase
    implements
        UseCase<
          FetchRestaurantHomeCategoryProductsModel,
          FetchRestaurantHomeCategoryProductsParams
        > {
  final RsHomeRepo rsHomeRepo;

  FetchRestaurantHomeCategoryProductsUseCase({required this.rsHomeRepo});

  @override
  DataResponse<FetchRestaurantHomeCategoryProductsModel> call(
    FetchRestaurantHomeCategoryProductsParams params,
  ) {
    return rsHomeRepo.fetchRestaurantHomeCategoryProducts(params);
  }
}

class FetchRestaurantHomeCategoryProductsParams with Params {
  final int categoryId;
  final int page;
  final int perPage;

  FetchRestaurantHomeCategoryProductsParams({
    required this.categoryId,
    this.page = 1,
    this.perPage = 20,
  });

  @override
  QueryParams getParams() => {
    'categoryId': categoryId,
    'page': page,
    'perPage': perPage,
  };
}
