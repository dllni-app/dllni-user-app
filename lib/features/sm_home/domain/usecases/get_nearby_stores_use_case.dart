import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/typedef.dart';

import '../repository/sm_home_repo.dart';
import '../../data/models/get_nearby_stores_model.dart';

@lazySingleton
class GetNearbyStoresUseCase
    implements UseCase<GetNearbyStoresModel, GetNearbyStoresParams> {
  final SmHomeRepo smHome;

  GetNearbyStoresUseCase({required this.smHome});

  @override
  DataResponse<GetNearbyStoresModel> call(GetNearbyStoresParams params) {
    return smHome.getNearbyStores(params);
  }
}

class GetNearbyStoresParams with Params {
  final double? latitude;
  final double? longitude;
  final int? limit;

  GetNearbyStoresParams({this.latitude, this.longitude, this.limit});

  @override
  QueryParams getParams() => {
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    if (limit != null) 'limit': limit,
  };
}
