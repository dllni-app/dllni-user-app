import 'package:common_package/helpers/typedef.dart';

import '../../data/models/luck_box_api_models.dart';
import '../../data/models/profile_api_models.dart';
import '../usecases/add_favorite_restaurant_use_case.dart';
import '../models/personal_details_update_input.dart';
import '../usecases/fetch_addresses_use_case.dart';
import '../usecases/fetch_favorite_restaurants_use_case.dart';
import '../usecases/fetch_notifications_use_case.dart';
import '../usecases/fetch_vote_suggestions_use_case.dart';
import '../usecases/create_vote_use_case.dart';
import '../usecases/create_address_use_case.dart';
import '../usecases/show_vote_use_case.dart';
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
}
