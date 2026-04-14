import 'package:injectable/injectable.dart';
import 'package:common_package/common_package.dart';
import 'package:common_package/helpers/typedef.dart';

import '../../domain/usecases/fetch_addresses_use_case.dart';
import '../../domain/usecases/fetch_favorite_restaurants_use_case.dart';
import '../../domain/usecases/fetch_notifications_use_case.dart';
import '../../domain/usecases/fetch_vote_suggestions_use_case.dart';
import '../../domain/usecases/create_vote_use_case.dart';
import '../../domain/usecases/create_address_use_case.dart';
import '../../domain/usecases/show_vote_use_case.dart';
import '../../domain/usecases/end_vote_use_case.dart';
import '../../domain/usecases/fetch_active_votes_use_case.dart';
import '../../domain/usecases/add_favorite_restaurant_use_case.dart';
import '../../domain/usecases/remove_favorite_restaurant_use_case.dart';
import '../../domain/usecases/set_default_address_use_case.dart';
import '../../domain/usecases/update_address_use_case.dart';
import '../../domain/usecases/delete_address_use_case.dart';
import '../../domain/usecases/update_account_use_case.dart';
import '../../domain/usecases/update_account_password_use_case.dart';
import '../models/luck_box_api_models.dart';
import '../models/profile_api_models.dart';

@lazySingleton
class ProfileRemoteDataSource with HandlingApiManager {
  final DioNetwork dioNetwork;

  ProfileRemoteDataSource({required this.dioNetwork});

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

  Future<FetchCouponsModel> fetchCoupons(NoParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/restaurants/coupons',
        params: params.getParams(),
        data: params.getBody().isEmpty ? null : params.getBody(),
      ),
      jsonConvert: fetchCouponsModelFromJson,
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

  Future<ActionResultModel> markAllNotificationsRead(NoParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.patchData(
        endPoint: '/api/v1/user/notifications/read-all',
        data: params.getBody().isEmpty ? {} : params.getBody(),
      ),
      jsonConvert: actionResultModelFromJson,
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

  Future<VoteSuggestionsModel> fetchVoteSuggestions(
    FetchVoteSuggestionsParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/restaurants/votes/suggestions',
        params: params.getParams(),
      ),
      jsonConvert: voteSuggestionsModelFromJson,
    );
  }

  Future<ActionResultModel> createAddress(CreateAddressParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint: '/api/v1/user/addresses',
        data: params.getBody().isEmpty ? {} : params.getBody(),
      ),
      jsonConvert: actionResultModelFromJson,
    );
  }

  Future<ActionResultModel> updateAddress(UpdateAddressParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.putData(
        endPoint: '/api/v1/user/addresses/${params.addressId}',
        data: params.getBody().isEmpty ? {} : params.getBody(),
      ),
      jsonConvert: actionResultModelFromJson,
    );
  }

  Future<ActionResultModel> deleteAddress(DeleteAddressParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.deleteData(
        endPoint: '/api/v1/user/addresses/${params.addressId}',
      ),
      jsonConvert: actionResultModelFromJson,
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

  Future<FetchActiveVotesModel> fetchActiveVotes(
    FetchActiveVotesParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/restaurants/votes/active',
        params: params.getParams(),
        data: params.getBody().isEmpty ? null : params.getBody(),
      ),
      jsonConvert: fetchActiveVotesModelFromJson,
    );
  }

  Future<UpdateAccountModel> updateAccount(UpdateAccountParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.patchData(
        endPoint: '/api/v1/user/account',
        data: params.getBody().isEmpty ? {} : params.getBody(),
      ),
      jsonConvert: updateAccountModelFromJson,
    );
  }

  Future<ActionResultModel> updateAccountPassword(
    UpdateAccountPasswordParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.putData(
        endPoint: '/api/v1/user/account/password',
        data: params.getBody().isEmpty ? {} : params.getBody(),
      ),
      jsonConvert: actionResultModelFromJson,
    );
  }

  Future<LuckBoxOptionsModel> fetchLuckBoxOptions() {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/restaurants/luck-box/options',
      ),
      jsonConvert: luckBoxOptionsModelFromJson,
    );
  }

  Future<LuckBoxSuggestResponseModel> suggestLuckBox(
    SuggestLuckBoxParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint: '/api/v1/user/restaurants/luck-box/suggest',
        data: params.getBody(),
      ),
      jsonConvert: luckBoxSuggestResponseModelFromJson,
    );
  }
}
