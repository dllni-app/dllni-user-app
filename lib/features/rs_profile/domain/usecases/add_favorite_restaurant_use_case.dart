import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/rs_profile_api_models.dart';
import '../repository/rs_profile_repo.dart';

@lazySingleton
class AddFavoriteRestaurantUseCase
    implements UseCase<ActionResultModel, AddFavoriteRestaurantParams> {
  final RsProfileRepo rsProfileRepo;

  AddFavoriteRestaurantUseCase({required this.rsProfileRepo});

  @override
  DataResponse<ActionResultModel> call(AddFavoriteRestaurantParams params) {
    return rsProfileRepo.addFavoriteRestaurant(params);
  }
}

class AddFavoriteRestaurantParams with Params {
  final int restaurantId;

  AddFavoriteRestaurantParams({required this.restaurantId});

  @override
  BodyMap getBody() => {};
}
