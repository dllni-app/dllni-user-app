import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../../sm_discover/data/models/browse_products_model.dart';
import '../repository/sm_favorite_repo.dart';

@lazySingleton
class GetFavoriteSupermarketProductsUseCase
    implements UseCase<BrowseProductsModel, GetFavoriteSupermarketProductsParams> {
  final SmFavoriteRepo smFavorite;

  GetFavoriteSupermarketProductsUseCase({required this.smFavorite});

  @override
  DataResponse<BrowseProductsModel> call(
    GetFavoriteSupermarketProductsParams params,
  ) {
    return smFavorite.getFavoriteSupermarketProducts(params);
  }
}

class GetFavoriteSupermarketProductsParams with Params {
  final int page;
  final int perPage;

  GetFavoriteSupermarketProductsParams({this.page = 1, this.perPage = 10});

  @override
  QueryParams getParams() => {'page': page, 'per_page': perPage};
}
