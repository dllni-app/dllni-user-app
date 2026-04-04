import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/fetch_restaurant_home_nearest_restaurants_model.dart';
import '../repository/rs_home_repo.dart';

@lazySingleton
class FetchRestaurantHomeNearestRestaurantsUseCase
    implements UseCase<FetchRestaurantHomeNearestRestaurantsModel, FetchRestaurantHomeNearestRestaurantsParams> {
  final RsHomeRepo rsHomeRepo;

  FetchRestaurantHomeNearestRestaurantsUseCase({required this.rsHomeRepo});

  @override
  DataResponse<FetchRestaurantHomeNearestRestaurantsModel> call(FetchRestaurantHomeNearestRestaurantsParams params) {
    return rsHomeRepo.fetchRestaurantHomeNearestRestaurants(params);
  }
}

class FetchRestaurantHomeNearestRestaurantsParams with Params {
  final int limit;
  final double? latitude;
  final double? longitude;

  FetchRestaurantHomeNearestRestaurantsParams({this.limit = 15, this.latitude, this.longitude});

  @override
  QueryParams getParams() => {
        'limit': limit,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };
}
