import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/typedef.dart';

import '../repository/sm_discover_repo.dart';
import '../../data/models/change_store_favorite_model.dart';

@lazySingleton
class ChangeStoreFavoriteUseCase
    implements UseCase<ChangeStoreFavoriteModel, ChangeStoreFavoriteParams> {
  final SmDiscoverRepo smDiscover;

  ChangeStoreFavoriteUseCase({required this.smDiscover});

  @override
  DataResponse<ChangeStoreFavoriteModel> call(
    ChangeStoreFavoriteParams params,
  ) {
    return smDiscover.changeStoreFavorite(params);
  }
}

class ChangeStoreFavoriteParams with Params {
  final bool isFavorite;
  final int storeId;

  ChangeStoreFavoriteParams({required this.isFavorite, required this.storeId});
}
