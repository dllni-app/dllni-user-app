import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/typedef.dart';

import '../repository/rs_favourite_repo.dart';

@lazySingleton
class ToggleProductFavouriteUseCase implements UseCase<bool, ToggleProductFavouriteParams> {
  final RsFavouriteRepo rsFavourite;

  ToggleProductFavouriteUseCase({required this.rsFavourite});

  @override
  DataResponse<bool> call(ToggleProductFavouriteParams params) {
    if (params.isFavorited) {
      return rsFavourite.addProductToFavourites(params.productId);
    }
    return rsFavourite.removeProductFromFavourites(params.productId);
  }
}

class ToggleProductFavouriteParams with Params {
  final int productId;
  final bool isFavorited;

  ToggleProductFavouriteParams({
    required this.productId,
    required this.isFavorited,
  });
}
