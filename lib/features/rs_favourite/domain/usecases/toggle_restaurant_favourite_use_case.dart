import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/typedef.dart';

import '../repository/rs_favourite_repo.dart';

@lazySingleton
class ToggleRestaurantFavouriteUseCase implements UseCase<bool, ToggleRestaurantFavouriteParams> {
  final RsFavouriteRepo rsFavourite;

  ToggleRestaurantFavouriteUseCase({required this.rsFavourite});

  @override
  DataResponse<bool> call(ToggleRestaurantFavouriteParams params) {
    if (params.isFavorited) {
      return rsFavourite.addRestaurantToFavourites(params.restaurantId);
    }
    return rsFavourite.removeRestaurantFromFavourites(params.restaurantId);
  }
}

class ToggleRestaurantFavouriteParams with Params {
  final int restaurantId;
  final bool isFavorited;

  ToggleRestaurantFavouriteParams({
    required this.restaurantId,
    required this.isFavorited,
  });
}
