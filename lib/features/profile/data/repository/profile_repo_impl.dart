import 'package:common_package/common_package.dart';
import 'package:injectable/injectable.dart';

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
import '../source/profile_remote_data_source.dart';
import '../../domain/models/personal_details_update_input.dart';
import '../../domain/repository/profile_repo.dart';
import 'package:common_package/helpers/typedef.dart';
import '../../domain/usecases/get_shopping_list_use_case.dart';
import '../models/get_shopping_list_model.dart';
import '../../domain/usecases/add_shopping_list_to_cart_use_case.dart';
import '../models/add_shopping_list_to_cart_model.dart';

@LazySingleton(as: ProfileRepo)
class ProfileRepoImpl with HandlingException implements ProfileRepo {
  final ProfileRemoteDataSource profileRemoteDataSource;

  ProfileRepoImpl({required this.profileRemoteDataSource});

  @override
  DataResponse<FetchFavoriteRestaurantsModel> fetchFavoriteRestaurants(
    FetchFavoriteRestaurantsParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => profileRemoteDataSource.fetchFavoriteRestaurants(params),
    );
  }

  @override
  DataResponse<FetchAddressesModel> fetchAddresses(
    FetchAddressesParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => profileRemoteDataSource.fetchAddresses(params),
    );
  }

  @override
  DataResponse<FetchCouponsModel> fetchCoupons(NoParams params) {
    return wrapHandlingException(
      tryCall: () => profileRemoteDataSource.fetchCoupons(params),
    );
  }

  @override
  DataResponse<FetchNotificationsPageModel> fetchNotifications(
    FetchNotificationsParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => profileRemoteDataSource.fetchNotifications(params),
    );
  }

  @override
  DataResponse<ActionResultModel> markAllNotificationsRead(NoParams params) {
    return wrapHandlingException(
      tryCall: () => profileRemoteDataSource.markAllNotificationsRead(params),
    );
  }

  @override
  DataResponse<ActionResultModel> removeFavoriteRestaurant(
    RemoveFavoriteRestaurantParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => profileRemoteDataSource.removeFavoriteRestaurant(params),
    );
  }

  @override
  DataResponse<ActionResultModel> addFavoriteRestaurant(
    AddFavoriteRestaurantParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => profileRemoteDataSource.addFavoriteRestaurant(params),
    );
  }

  @override
  DataResponse<ActionResultModel> setDefaultAddress(
    SetDefaultAddressParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => profileRemoteDataSource.setDefaultAddress(params),
    );
  }

  @override
  DataResponse<CreateVoteModel> createVote(CreateVoteParams params) {
    return wrapHandlingException(
      tryCall: () => profileRemoteDataSource.createVote(params),
    );
  }

  @override
  DataResponse<VoteSuggestionsModel> fetchVoteSuggestions(
    FetchVoteSuggestionsParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => profileRemoteDataSource.fetchVoteSuggestions(params),
    );
  }

  @override
  DataResponse<ActionResultModel> createAddress(CreateAddressParams params) {
    return wrapHandlingException(
      tryCall: () => profileRemoteDataSource.createAddress(params),
    );
  }

  @override
  DataResponse<ActionResultModel> updateAddress(UpdateAddressParams params) {
    return wrapHandlingException(
      tryCall: () => profileRemoteDataSource.updateAddress(params),
    );
  }

  @override
  DataResponse<ActionResultModel> deleteAddress(DeleteAddressParams params) {
    return wrapHandlingException(
      tryCall: () => profileRemoteDataSource.deleteAddress(params),
    );
  }

  @override
  DataResponse<ShowVoteModel> showVote(ShowVoteParams params) {
    return wrapHandlingException(
      tryCall: () => profileRemoteDataSource.showVote(params),
    );
  }

  @override
  DataResponse<ActionResultModel> endVote(EndVoteParams params) {
    return wrapHandlingException(
      tryCall: () => profileRemoteDataSource.endVote(params),
    );
  }

  @override
  DataResponse<FetchActiveVotesModel> fetchActiveVotes(
    FetchActiveVotesParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => profileRemoteDataSource.fetchActiveVotes(params),
    );
  }

  @override
  DataResponse<LuckBoxOptionsModel> fetchLuckBoxOptions() {
    return wrapHandlingException(
      tryCall: () => profileRemoteDataSource.fetchLuckBoxOptions(),
    );
  }

  @override
  DataResponse<LuckBoxSuggestResponseModel> suggestLuckBox(
    SuggestLuckBoxParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => profileRemoteDataSource.suggestLuckBox(params),
    );
  }

  @override
  DataResponse<UpdateAccountModel> updateAccount(UpdateAccountParams params) {
    return wrapHandlingException(
      tryCall: () => profileRemoteDataSource.updateAccount(params),
    );
  }

  @override
  DataResponse<ActionResultModel> updateAccountPassword(
    UpdateAccountPasswordParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => profileRemoteDataSource.updateAccountPassword(params),
    );
  }

  @override
  Future<void> updatePersonalDetails(PersonalDetailsUpdateInput input) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
  }


  @override
  DataResponse<GetShoppingListModel> getShoppingList(GetShoppingListParams params) {
    return wrapHandlingException(
      tryCall: () => profileRemoteDataSource.getShoppingList(params),
    );
  }

  @override
  DataResponse<AddShoppingListToCartModel> addShoppingListToCart(AddShoppingListToCartParams params) {
    return wrapHandlingException(
      tryCall: () => profileRemoteDataSource.addShoppingListToCart(params),
    );
  }}
