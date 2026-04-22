import 'package:injectable/injectable.dart';
import 'package:common_package/common_package.dart';

import '../../domain/usecases/fetch_addresses_use_case.dart';
import '../../domain/usecases/fetch_favorite_restaurants_use_case.dart';
import '../../domain/usecases/fetch_notifications_use_case.dart';
import '../../domain/usecases/mark_notification_read_use_case.dart';
import '../../domain/usecases/fetch_vote_suggestions_use_case.dart';
import '../../domain/usecases/create_vote_use_case.dart';
import '../../domain/usecases/create_address_use_case.dart';
import '../../domain/usecases/show_vote_use_case.dart';
import '../../domain/usecases/submit_vote_ballot_use_case.dart';
import '../../domain/usecases/end_vote_use_case.dart';
import '../../domain/usecases/fetch_active_votes_use_case.dart';
import '../../domain/usecases/add_favorite_restaurant_use_case.dart';
import '../../domain/usecases/remove_favorite_restaurant_use_case.dart';
import '../../domain/usecases/set_default_address_use_case.dart';
import '../../domain/usecases/update_address_use_case.dart';
import '../../domain/usecases/delete_address_use_case.dart';
import '../../domain/usecases/update_account_use_case.dart';
import '../../domain/usecases/update_account_password_use_case.dart';
import '../../domain/usecases/create_group_order_use_case.dart';
import '../../domain/usecases/join_group_order_use_case.dart';
import '../../domain/usecases/fetch_active_group_orders_use_case.dart';
import '../../domain/usecases/fetch_group_order_menu_sections_use_case.dart';
import '../../domain/usecases/show_group_order_use_case.dart';
import '../../domain/usecases/add_group_order_item_use_case.dart';
import '../../domain/usecases/update_group_order_item_use_case.dart';
import '../../domain/usecases/delete_group_order_item_use_case.dart';
import '../../domain/usecases/submit_group_order_use_case.dart';
import '../../domain/usecases/unsubmit_group_order_use_case.dart';
import '../../domain/usecases/cancel_group_order_use_case.dart';
import '../../domain/usecases/place_group_order_use_case.dart';
import '../models/luck_box_api_models.dart';
import '../models/profile_api_models.dart';
import '../models/group_order_api_models.dart';
import '../models/get_shopping_list_model.dart';
import '../../domain/usecases/get_shopping_list_use_case.dart';
import '../models/add_shopping_list_to_cart_model.dart';
import '../../domain/usecases/add_shopping_list_to_cart_use_case.dart';

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

  Future<ActionResultModel> markNotificationRead(MarkNotificationReadParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.patchData(
        endPoint: '/api/v1/user/notifications/${params.notificationId}/read',
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

  Future<ActionResultModel> submitVoteBallot(SubmitVoteBallotParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint: '/api/v1/user/restaurants/votes/${params.voteId}/ballots',
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


  Future<GetShoppingListModel> getShoppingList(GetShoppingListParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(endPoint: '/api/v1/user/supermarket/shopping-lists', params: params.getParams(), data: params.getBody().isEmpty ? null : params.getBody()),
      jsonConvert: getShoppingListModelFromJson,
    );
  }

  Future<AddShoppingListToCartModel> addShoppingListToCart(AddShoppingListToCartParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(endPoint: '/api/v1/user/supermarket/shopping-lists/{{smShoppingListId}}/add-to-cart', data: params.getBody(), params: params.getParams()),
      jsonConvert: addShoppingListToCartModelFromJson,
    );
  }

  Future<GroupOrderActionModel> createGroupOrder(CreateGroupOrderParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint: '/api/v1/user/restaurants/group-orders',
        data: params.getBody(),
      ),
      jsonConvert: groupOrderActionModelFromJson,
    );
  }

  Future<GroupOrderActionModel> joinGroupOrder(JoinGroupOrderParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint: '/api/v1/user/restaurants/group-orders/join',
        data: params.getBody(),
      ),
      jsonConvert: groupOrderActionModelFromJson,
    );
  }

  Future<GroupOrderActiveListModel> fetchActiveGroupOrders(
    FetchActiveGroupOrdersParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/restaurants/group-orders/active',
        params: params.getParams(),
        data: params.getBody().isEmpty ? null : params.getBody(),
      ),
      jsonConvert: groupOrderActiveListModelFromJson,
    );
  }

  Future<GroupOrderDetailsModel> showGroupOrder(ShowGroupOrderParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/restaurants/group-orders/${params.groupOrderId}',
      ),
      jsonConvert: groupOrderDetailsModelFromJson,
    );
  }

  Future<GroupOrderMenuSectionsResponseModel> fetchGroupOrderMenuSections(
    FetchGroupOrderMenuSectionsParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint:
            '/api/v1/user/restaurants/${params.restaurantId}/menu-sections',
        params: params.getParams(),
      ),
      jsonConvert: groupOrderMenuSectionsResponseModelFromJson,
    );
  }

  Future<GroupOrderActionModel> addGroupOrderItem(AddGroupOrderItemParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint: '/api/v1/user/restaurants/group-orders/${params.groupOrderId}/items',
        data: params.getBody(),
      ),
      jsonConvert: groupOrderActionModelFromJson,
    );
  }

  Future<GroupOrderActionModel> updateGroupOrderItem(
    UpdateGroupOrderItemParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.patchData(
        endPoint: '/api/v1/user/restaurants/group-orders/${params.groupOrderId}/items/${params.itemId}',
        data: params.getBody(),
      ),
      jsonConvert: groupOrderActionModelFromJson,
    );
  }

  Future<GroupOrderActionModel> deleteGroupOrderItem(
    DeleteGroupOrderItemParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.deleteData(
        endPoint: '/api/v1/user/restaurants/group-orders/${params.groupOrderId}/items/${params.itemId}',
      ),
      jsonConvert: groupOrderActionModelFromJson,
    );
  }

  Future<GroupOrderActionModel> submitGroupOrder(SubmitGroupOrderParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint: '/api/v1/user/restaurants/group-orders/${params.groupOrderId}/submit',
        data: params.getBody().isEmpty ? {} : params.getBody(),
      ),
      jsonConvert: groupOrderActionModelFromJson,
    );
  }

  Future<GroupOrderActionModel> unsubmitGroupOrder(
    UnsubmitGroupOrderParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint: '/api/v1/user/restaurants/group-orders/${params.groupOrderId}/unsubmit',
        data: params.getBody().isEmpty ? {} : params.getBody(),
      ),
      jsonConvert: groupOrderActionModelFromJson,
    );
  }

  Future<GroupOrderActionModel> cancelGroupOrder(CancelGroupOrderParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint: '/api/v1/user/restaurants/group-orders/${params.groupOrderId}/cancel',
        data: params.getBody().isEmpty ? {} : params.getBody(),
      ),
      jsonConvert: groupOrderActionModelFromJson,
    );
  }

  Future<GroupOrderActionModel> placeGroupOrder(PlaceGroupOrderParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint: '/api/v1/user/restaurants/group-orders/${params.groupOrderId}/place',
        data: params.getBody().isEmpty ? {} : params.getBody(),
      ),
      jsonConvert: groupOrderActionModelFromJson,
    );
  }
}
