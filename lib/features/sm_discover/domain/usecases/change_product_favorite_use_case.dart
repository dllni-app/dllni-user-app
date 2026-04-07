import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/typedef.dart';

import '../repository/sm_discover_repo.dart';
import '../../data/models/change_product_favorite_model.dart';

@lazySingleton
class ChangeProductFavoriteUseCase implements UseCase<ChangeProductFavoriteModel, ChangeProductFavoriteParams> {

  final SmDiscoverRepo smDiscover;

  ChangeProductFavoriteUseCase({required this.smDiscover});

  @override
  DataResponse<ChangeProductFavoriteModel> call(ChangeProductFavoriteParams params) {
    return smDiscover.changeProductFavorite(params);
  }
}

class ChangeProductFavoriteParams with Params{
  final bool isFavorite;
  final int productId;

  ChangeProductFavoriteParams({required this.isFavorite, required this.productId});
}
