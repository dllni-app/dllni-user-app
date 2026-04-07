import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/typedef.dart';

import '../repository/sm_home_repo.dart';
import '../../data/models/get_nearby_stores_model.dart';

@lazySingleton
class GetNearbyStoresUseCase implements UseCase<GetNearbyStoresModel, GetNearbyStoresParams> {

  final SmHomeRepo smHome;

  GetNearbyStoresUseCase({required this.smHome});

  @override
  DataResponse<GetNearbyStoresModel> call(GetNearbyStoresParams params) {
    return smHome.getNearbyStores(params);
  }
}

class GetNearbyStoresParams with Params{}
