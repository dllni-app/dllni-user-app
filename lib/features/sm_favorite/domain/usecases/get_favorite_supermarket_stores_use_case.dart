import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../../sm_discover/data/models/browse_stores_model.dart';
import '../repository/sm_favorite_repo.dart';

@lazySingleton
class GetFavoriteSupermarketStoresUseCase
    implements
        UseCase<BrowseStoresModel, GetFavoriteSupermarketStoresParams> {
  final SmFavoriteRepo smFavorite;

  GetFavoriteSupermarketStoresUseCase({required this.smFavorite});

  @override
  DataResponse<BrowseStoresModel> call(GetFavoriteSupermarketStoresParams params) {
    return smFavorite.getFavoriteSupermarketStores(params);
  }
}

class GetFavoriteSupermarketStoresParams with Params {
  final int page;
  final int perPage;

  GetFavoriteSupermarketStoresParams({this.page = 1, this.perPage = 10});

  @override
  QueryParams getParams() => {'page': page, 'per_page': perPage};
}
