import 'package:injectable/injectable.dart';
import 'package:common_package/common_package.dart';

import '../../domain/usecases/fetch_addresses_use_case.dart';
import '../../domain/usecases/fetch_favorite_restaurants_use_case.dart';
import '../../domain/usecases/fetch_notifications_use_case.dart';
import '../../domain/usecases/create_vote_use_case.dart';
import '../../domain/usecases/show_vote_use_case.dart';
import '../../domain/usecases/end_vote_use_case.dart';
import '../../domain/usecases/add_favorite_restaurant_use_case.dart';
import '../../domain/usecases/remove_favorite_restaurant_use_case.dart';
import '../../domain/usecases/set_default_address_use_case.dart';
import '../models/rs_profile_api_models.dart';

@lazySingleton
class RsProfileRemoteDataSource with HandlingApiManager {
  final DioNetwork dioNetwork;

  RsProfileRemoteDataSource({required this.dioNetwork});

  Future<FetchFavoriteRestaurantsModel> fetchFavoriteRestaurants(
    FetchFavoriteRestaurantsParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/favorites/restaurants',
        params: params.getParams(),
        data: params.getBody().isEmpty ? null : params.getBody(),
      ),
      jsonConvert: fetchFavoriteRestaurantsModelFromJson,
    );
  }

  Future<FetchAddressesModel> fetchAddresses(FetchAddressesParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/addresses',
        params: params.getParams(),
        data: params.getBody().isEmpty ? null : params.getBody(),
      ),
      jsonConvert: fetchAddressesModelFromJson,
    );
  }

  Future<FetchNotificationsPageModel> fetchNotifications(
    FetchNotificationsParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/notifications',
        params: params.getParams(),
        data: params.getBody().isEmpty ? null : params.getBody(),
      ),
      jsonConvert: fetchNotificationsPageModelFromJson,
    );
  }

  Future<ActionResultModel> removeFavoriteRestaurant(
    RemoveFavoriteRestaurantParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.deleteData(
        endPoint: '/api/v1/user/favorites/restaurants/${params.restaurantId}',
      ),
      jsonConvert: actionResultModelFromJson,
    );
  }

  Future<ActionResultModel> addFavoriteRestaurant(
    AddFavoriteRestaurantParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint: '/api/v1/user/favorites/restaurants/${params.restaurantId}',
        data: params.getBody().isEmpty ? {} : params.getBody(),
      ),
      jsonConvert: actionResultModelFromJson,
    );
  }

  Future<ActionResultModel> setDefaultAddress(SetDefaultAddressParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.patchData(
        endPoint: '/api/v1/user/addresses/${params.addressId}/set-default',
        data: params.getBody().isEmpty ? {} : params.getBody(),
      ),
      jsonConvert: actionResultModelFromJson,
    );
  }

  Future<CreateVoteModel> createVote(CreateVoteParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint: '/api/v1/user/restaurants/votes',
        data: params.getBody().isEmpty ? {} : params.getBody(),
      ),
      jsonConvert: createVoteModelFromJson,
    );
  }

  Future<ShowVoteModel> showVote(ShowVoteParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/restaurants/votes/${params.voteId}',
      ),
      jsonConvert: showVoteModelFromJson,
    );
  }

  Future<ActionResultModel> endVote(EndVoteParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint: '/api/v1/user/restaurants/votes/${params.voteId}/end',
        data: params.getBody().isEmpty ? {} : params.getBody(),
      ),
      jsonConvert: actionResultModelFromJson,
    );
  }
}
