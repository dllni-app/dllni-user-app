import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/typedef.dart';

import '../repository/rs_home_repo.dart';
import '../../data/models/fetch_near_by_stores_model.dart';

@lazySingleton
class FetchNearByStoresUseCase implements UseCase<FetchNearByStoresModel, FetchNearByStoresParams> {

  final RsHomeRepo rsHome;

  FetchNearByStoresUseCase({required this.rsHome});

  @override
  DataResponse<FetchNearByStoresModel> call(FetchNearByStoresParams params) {
    return rsHome.fetchNearByStores(params);
  }
}

class FetchNearByStoresParams with Params{}
