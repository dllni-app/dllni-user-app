import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/rs_profile_api_models.dart';
import '../repository/rs_profile_repo.dart';

@lazySingleton
class RemoveFavoriteRestaurantUseCase
    implements UseCase<ActionResultModel, RemoveFavoriteRestaurantParams> {
  final RsProfileRepo rsProfileRepo;

  RemoveFavoriteRestaurantUseCase({required this.rsProfileRepo});

  @override
  DataResponse<ActionResultModel> call(RemoveFavoriteRestaurantParams params) {
    return rsProfileRepo.removeFavoriteRestaurant(params);
  }
}

class RemoveFavoriteRestaurantParams with Params {
  final int restaurantId;

  RemoveFavoriteRestaurantParams({required this.restaurantId});
}
