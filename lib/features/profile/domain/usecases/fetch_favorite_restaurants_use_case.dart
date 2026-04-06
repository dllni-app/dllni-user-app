import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/profile_api_models.dart';
import '../repository/profile_repo.dart';

@lazySingleton
class FetchFavoriteRestaurantsUseCase
    implements
        UseCase<FetchFavoriteRestaurantsModel, FetchFavoriteRestaurantsParams> {
  final ProfileRepo profileRepo;

  FetchFavoriteRestaurantsUseCase({required this.profileRepo});

  @override
  DataResponse<FetchFavoriteRestaurantsModel> call(
    FetchFavoriteRestaurantsParams params,
  ) {
    return profileRepo.fetchFavoriteRestaurants(params);
  }
}

class FetchFavoriteRestaurantsParams with Params {
  final int page;
  final int perPage;

  FetchFavoriteRestaurantsParams({this.page = 1, this.perPage = 20});

  @override
  QueryParams getParams() => {'page': page, 'perPage': perPage};
}
