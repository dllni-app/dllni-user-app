import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/fetch_restaurant_home_suggested_products_model.dart';
import '../repository/rs_home_repo.dart';

@lazySingleton
class FetchRestaurantHomeSuggestedProductsUseCase
    implements UseCase<FetchRestaurantHomeSuggestedProductsModel, FetchRestaurantHomeSuggestedProductsParams> {
  final RsHomeRepo rsHomeRepo;

  FetchRestaurantHomeSuggestedProductsUseCase({required this.rsHomeRepo});

  @override
  DataResponse<FetchRestaurantHomeSuggestedProductsModel> call(FetchRestaurantHomeSuggestedProductsParams params) {
    return rsHomeRepo.fetchRestaurantHomeSuggestedProducts(params);
  }
}

class FetchRestaurantHomeSuggestedProductsParams with Params {
  final int limit;

  FetchRestaurantHomeSuggestedProductsParams({this.limit = 15});

  @override
  QueryParams getParams() => {'limit': limit};
}
