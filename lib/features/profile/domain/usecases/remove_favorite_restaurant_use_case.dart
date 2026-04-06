import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/profile_api_models.dart';
import '../repository/profile_repo.dart';

@lazySingleton
class RemoveFavoriteRestaurantUseCase
    implements UseCase<ActionResultModel, RemoveFavoriteRestaurantParams> {
  final ProfileRepo profileRepo;

  RemoveFavoriteRestaurantUseCase({required this.profileRepo});

  @override
  DataResponse<ActionResultModel> call(RemoveFavoriteRestaurantParams params) {
    return profileRepo.removeFavoriteRestaurant(params);
  }
}

class RemoveFavoriteRestaurantParams with Params {
  final int restaurantId;

  RemoveFavoriteRestaurantParams({required this.restaurantId});
}
