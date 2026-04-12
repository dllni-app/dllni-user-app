import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/typedef.dart';

import '../repository/sm_home_repo.dart';
import '../../data/models/change_store_favorite_model.dart';

@lazySingleton
class ChangeStoreFavoriteUseCase
    implements UseCase<ChangeStoreFavoriteModel, ChangeStoreFavoriteParams> {
  final SmHomeRepo smHome;

  ChangeStoreFavoriteUseCase({required this.smHome});

  @override
  DataResponse<ChangeStoreFavoriteModel> call(
    ChangeStoreFavoriteParams params,
  ) {
    return smHome.changeStoreFavorite(params);
  }
}

class ChangeStoreFavoriteParams with Params {
  final bool isFavorite;
  final int storeId;

  ChangeStoreFavoriteParams({required this.storeId, required this.isFavorite});
}
