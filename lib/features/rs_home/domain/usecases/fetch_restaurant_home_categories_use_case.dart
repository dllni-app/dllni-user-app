import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/fetch_restaurant_home_categories_model.dart';
import '../repository/rs_home_repo.dart';

@lazySingleton
class FetchRestaurantHomeCategoriesUseCase implements UseCase<FetchRestaurantHomeCategoriesModel, FetchRestaurantHomeCategoriesParams> {
  final RsHomeRepo rsHomeRepo;

  FetchRestaurantHomeCategoriesUseCase({required this.rsHomeRepo});

  @override
  DataResponse<FetchRestaurantHomeCategoriesModel> call(FetchRestaurantHomeCategoriesParams params) {
    return rsHomeRepo.fetchRestaurantHomeCategories(params);
  }
}

class FetchRestaurantHomeCategoriesParams with Params {}
