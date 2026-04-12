import 'package:common_package/common_package.dart';
import 'package:injectable/injectable.dart';
import '../models/get_featured_offers_model.dart';
import '../../domain/usecases/get_featured_offers_use_case.dart';
import '../models/get_nearby_stores_model.dart';
import '../../domain/usecases/get_nearby_stores_use_case.dart';
import '../models/change_store_favorite_model.dart';
import '../../domain/usecases/change_store_favorite_use_case.dart';

@lazySingleton
class SmHomeRemoteDataSource with HandlingApiManager {
  final DioNetwork dioNetwork;

  SmHomeRemoteDataSource({required this.dioNetwork});

  Future<GetFeaturedOffersModel> getFeaturedOffers(
    GetFeaturedOffersParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/supermarket/home/featured-offers',
        params: params.getParams(),
        data: params.getBody().isEmpty ? null : params.getBody(),
      ),
      jsonConvert: getFeaturedOffersModelFromJson,
    );
  }

  Future<GetNearbyStoresModel> getNearbyStores(GetNearbyStoresParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/supermarket/home/nearby-stores',
        params: params.getParams(),
        data: params.getBody().isEmpty ? null : params.getBody(),
      ),
      jsonConvert: getNearbyStoresModelFromJson,
    );
  }

  Future<ChangeStoreFavoriteModel> changeStoreFavorite(
    ChangeStoreFavoriteParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => params.isFavorite
          ? dioNetwork.postData(
              endPoint:
                  '/api/v1/user/favorites/supermarket/stores/${params.storeId}',
              data: params.getBody(),
              params: params.getParams(),
            )
          : dioNetwork.deleteData(
              endPoint:
                  '/api/v1/user/favorites/supermarket/stores/${params.storeId}',
              data: params.getBody(),
              params: params.getParams(),
            ),
      jsonConvert: changeStoreFavoriteModelFromJson,
    );
  }
}
