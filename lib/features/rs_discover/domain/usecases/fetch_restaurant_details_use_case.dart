import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/fetch_restaurant_details_model.dart';
import '../repository/rs_discover_repo.dart';

@lazySingleton
class FetchRestaurantDetailsUseCase implements UseCase<FetchRestaurantDetailsModel, FetchRestaurantDetailsParams> {
  final RsDiscoverRepo rsDiscoverRepo;

  FetchRestaurantDetailsUseCase({required this.rsDiscoverRepo});

  @override
  DataResponse<FetchRestaurantDetailsModel> call(FetchRestaurantDetailsParams params) {
    return rsDiscoverRepo.fetchRestaurantDetails(params);
  }
}

class FetchRestaurantDetailsParams with Params {
  final int restaurantId;
  final int reviewsPerPage;

  FetchRestaurantDetailsParams({required this.restaurantId, this.reviewsPerPage = 10});

  @override
  QueryParams getParams() => {'reviewsPerPage': reviewsPerPage};
}
