import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/fetch_restaurant_home_exclusive_offers_model.dart';
import '../repository/rs_home_repo.dart';

@lazySingleton
class FetchRestaurantHomeExclusiveOffersUseCase
    implements UseCase<FetchRestaurantHomeExclusiveOffersModel, FetchRestaurantHomeExclusiveOffersParams> {
  final RsHomeRepo rsHomeRepo;

  FetchRestaurantHomeExclusiveOffersUseCase({required this.rsHomeRepo});

  @override
  DataResponse<FetchRestaurantHomeExclusiveOffersModel> call(FetchRestaurantHomeExclusiveOffersParams params) {
    return rsHomeRepo.fetchRestaurantHomeExclusiveOffers(params);
  }
}

class FetchRestaurantHomeExclusiveOffersParams with Params {
  final int limit;
  final double? latitude;
  final double? longitude;

  FetchRestaurantHomeExclusiveOffersParams({this.limit = 15, this.latitude, this.longitude});

  @override
  QueryParams getParams() => {
        'limit': limit,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };
}
