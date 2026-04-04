import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/typedef.dart';

import '../repository/rs_home_repo.dart';
import '../../data/models/fetch_stores_model.dart';

@lazySingleton
class FetchStoresUseCase implements UseCase<FetchStoresModel, FetchStoresParams> {

  final RsHomeRepo rsHome;

  FetchStoresUseCase({required this.rsHome});

  @override
  DataResponse<FetchStoresModel> call(FetchStoresParams params) {
    return rsHome.fetchStores(params);
  }
}

class FetchStoresParams with Params{}
