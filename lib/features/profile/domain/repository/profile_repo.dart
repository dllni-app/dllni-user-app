import 'package:common_package/helpers/typedef.dart';

import '../../data/models/luck_box_api_models.dart';
import '../../data/models/profile_api_models.dart';
import '../../data/models/group_order_api_models.dart';
import '../usecases/add_favorite_restaurant_use_case.dart';
import '../models/personal_details_update_input.dart';
import '../usecases/fetch_addresses_use_case.dart';
import '../usecases/fetch_favorite_restaurants_use_case.dart';
import '../usecases/fetch_notifications_use_case.dart';
import '../usecases/mark_notification_read_use_case.dart';
import '../usecases/fetch_vote_suggestions_use_case.dart';
import '../usecases/create_vote_use_case.dart';
import '../usecases/create_address_use_case.dart';
import '../usecases/show_vote_use_case.dart';
import '../usecases/submit_vote_ballot_use_case.dart';
import '../usecases/end_vote_use_case.dart';
import '../usecases/fetch_active_votes_use_case.dart';
import '../usecases/remove_favorite_restaurant_use_case.dart';
import '../usecases/set_default_address_use_case.dart';
import '../usecases/update_address_use_case.dart';
import '../usecases/delete_address_use_case.dart';
import '../usecases/update_account_use_case.dart';
import '../usecases/update_account_password_use_case.dart';
import '../usecases/get_shopping_list_use_case.dart';
import '../../data/models/get_shopping_list_model.dart';
import '../usecases/add_shopping_list_to_cart_use_case.dart';
import '../../data/models/add_shopping_list_to_cart_model.dart';
import '../usecases/create_group_order_use_case.dart';
import '../usecases/join_group_order_use_case.dart';
import '../usecases/fetch_active_group_orders_use_case.dart';
import '../usecases/fetch_group_order_menu_sections_use_case.dart';
import '../usecases/show_group_order_use_case.dart';
import '../usecases/add_group_order_item_use_case.dart';
import '../usecases/update_group_order_item_use_case.dart';
import '../usecases/delete_group_order_item_use_case.dart';
import '../usecases/submit_group_order_use_case.dart';
import '../usecases/unsubmit_group_order_use_case.dart';
import '../usecases/cancel_group_order_use_case.dart';
import '../usecases/place_group_order_use_case.dart';

abstract class ProfileRepo {
  DataResponse<FetchFavoriteRestaurantsModel> fetchFavoriteRestaurants(
    FetchFavoriteRestaurantsParams params,
  );

  DataResponse<FetchAddressesModel> fetchAddresses(FetchAddressesParams params);

  DataResponse<FetchCouponsModel> fetchCoupons(NoParams params);

  DataResponse<FetchNotificationsPageModel> fetchNotifications(
    FetchNotificationsParams params,
  );

  DataResponse<ActionResultModel> markAllNotificationsRead(NoParams params);

  DataResponse<ActionResultModel> markNotificationRead(MarkNotificationReadParams params);

  DataResponse<ActionResultModel> removeFavoriteRestaurant(
    RemoveFavoriteRestaurantParams params,
  );

  DataResponse<ActionResultModel> addFavoriteRestaurant(
    AddFavoriteRestaurantParams params,
  );

  DataResponse<ActionResultModel> setDefaultAddress(
    SetDefaultAddressParams params,
  );

  DataResponse<CreateVoteModel> createVote(CreateVoteParams params);

  DataResponse<VoteSuggestionsModel> fetchVoteSuggestions(
    FetchVoteSuggestionsParams params,
  );

  DataResponse<ActionResultModel> createAddress(CreateAddressParams params);

  DataResponse<ActionResultModel> updateAddress(UpdateAddressParams params);

  DataResponse<ActionResultModel> deleteAddress(DeleteAddressParams params);

  DataResponse<ShowVoteModel> showVote(ShowVoteParams params);

  DataResponse<ActionResultModel> submitVoteBallot(
    SubmitVoteBallotParams params,
  );

  DataResponse<ActionResultModel> endVote(EndVoteParams params);

  DataResponse<FetchActiveVotesModel> fetchActiveVotes(
    FetchActiveVotesParams params,
  );

  DataResponse<LuckBoxOptionsModel> fetchLuckBoxOptions();

  DataResponse<LuckBoxSuggestResponseModel> suggestLuckBox(
    SuggestLuckBoxParams params,
  );

  DataResponse<UpdateAccountModel> updateAccount(UpdateAccountParams params);

  DataResponse<ActionResultModel> updateAccountPassword(
    UpdateAccountPasswordParams params,
  );

  Future<void> updatePersonalDetails(PersonalDetailsUpdateInput input);

  DataResponse<GetShoppingListModel> getShoppingList(GetShoppingListParams params);

  DataResponse<AddShoppingListToCartModel> addShoppingListToCart(AddShoppingListToCartParams params);

  DataResponse<GroupOrderActionModel> createGroupOrder(CreateGroupOrderParams params);

  DataResponse<GroupOrderActionModel> joinGroupOrder(JoinGroupOrderParams params);

  DataResponse<GroupOrderActiveListModel> fetchActiveGroupOrders(
    FetchActiveGroupOrdersParams params,
  );

  DataResponse<GroupOrderDetailsModel> showGroupOrder(ShowGroupOrderParams params);

  DataResponse<GroupOrderMenuSectionsResponseModel> fetchGroupOrderMenuSections(
    FetchGroupOrderMenuSectionsParams params,
  );

  DataResponse<GroupOrderActionModel> addGroupOrderItem(AddGroupOrderItemParams params);

  DataResponse<GroupOrderActionModel> updateGroupOrderItem(
    UpdateGroupOrderItemParams params,
  );

  DataResponse<GroupOrderActionModel> deleteGroupOrderItem(
    DeleteGroupOrderItemParams params,
  );

  DataResponse<GroupOrderActionModel> submitGroupOrder(SubmitGroupOrderParams params);

  DataResponse<GroupOrderActionModel> unsubmitGroupOrder(
    UnsubmitGroupOrderParams params,
  );

  DataResponse<GroupOrderActionModel> cancelGroupOrder(CancelGroupOrderParams params);

  DataResponse<GroupOrderActionModel> placeGroupOrder(PlaceGroupOrderParams params);
}
