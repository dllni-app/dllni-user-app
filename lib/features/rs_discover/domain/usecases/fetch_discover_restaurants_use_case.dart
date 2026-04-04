import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/typedef.dart';

import '../repository/rs_discover_repo.dart';
import '../params/fetch_discover_restaurants_params.dart';
import '../../data/models/fetch_discover_restaurants_model.dart';

@lazySingleton
class FetchDiscoverRestaurantsUseCase implements UseCase<FetchDiscoverRestaurantsModel, FetchDiscoverRestaurantsParams> {
  final RsDiscoverRepo rsDiscoverRepo;

  FetchDiscoverRestaurantsUseCase({required this.rsDiscoverRepo});

  @override
  DataResponse<FetchDiscoverRestaurantsModel> call(FetchDiscoverRestaurantsParams params) {
    return rsDiscoverRepo.fetchDiscoverRestaurants(params);
  }
}
