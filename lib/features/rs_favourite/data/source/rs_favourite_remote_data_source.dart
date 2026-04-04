import 'package:common_package/common_package.dart';
import 'package:injectable/injectable.dart';
import '../models/fetch_rs_favourites_model.dart';
import '../../domain/usecases/fetch_rs_favourites_use_case.dart';

@lazySingleton
class RsFavouriteRemoteDataSource with HandlingApiManager {
  final DioNetwork dioNetwork;

  RsFavouriteRemoteDataSource({required this.dioNetwork});

  Future<FetchRsFavouritesModel> fetchRsFavourites(FetchRsFavouritesParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/favorites/restaurants',
        params: params.getParams(),
        data: params.getBody().isEmpty ? null : params.getBody(),
      ),
      jsonConvert: fetchRsFavouritesModelFromJson,
    );
  }
}
