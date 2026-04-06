import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/profile_api_models.dart';
import '../repository/profile_repo.dart';

@lazySingleton
class AddFavoriteRestaurantUseCase
    implements UseCase<ActionResultModel, AddFavoriteRestaurantParams> {
  final ProfileRepo profileRepo;

  AddFavoriteRestaurantUseCase({required this.profileRepo});

  @override
  DataResponse<ActionResultModel> call(AddFavoriteRestaurantParams params) {
    return profileRepo.addFavoriteRestaurant(params);
  }
}

class AddFavoriteRestaurantParams with Params {
  final int restaurantId;

  AddFavoriteRestaurantParams({required this.restaurantId});

  @override
  BodyMap getBody() => {};
}
