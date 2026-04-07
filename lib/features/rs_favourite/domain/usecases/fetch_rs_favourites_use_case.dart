import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/typedef.dart';

import '../repository/rs_favourite_repo.dart';
import '../../data/models/fetch_rs_favourites_model.dart';

@lazySingleton
class FetchRsFavouritesUseCase implements UseCase<FetchRsFavouritesModel, FetchRsFavouritesParams> {
  final RsFavouriteRepo rsFavourite;

  FetchRsFavouritesUseCase({required this.rsFavourite});

  @override
  DataResponse<FetchRsFavouritesModel> call(FetchRsFavouritesParams params) {
    return rsFavourite.fetchRsFavourites(params);
  }
}

class FetchRsFavouritesParams with Params {
  final int page;
  final int perPage;

  FetchRsFavouritesParams({required this.page, this.perPage = 10});

  @override
  QueryParams getParams() => {'page': page, 'per_page': perPage};
}
