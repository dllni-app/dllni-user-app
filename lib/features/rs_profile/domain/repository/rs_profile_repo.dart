import 'package:common_package/helpers/typedef.dart';

import '../../data/models/rs_profile_api_models.dart';
import '../usecases/add_favorite_restaurant_use_case.dart';
import '../models/rs_personal_details_update_input.dart';
import '../usecases/fetch_addresses_use_case.dart';
import '../usecases/fetch_favorite_restaurants_use_case.dart';
import '../usecases/fetch_notifications_use_case.dart';
import '../usecases/create_vote_use_case.dart';
import '../usecases/show_vote_use_case.dart';
import '../usecases/end_vote_use_case.dart';
import '../usecases/remove_favorite_restaurant_use_case.dart';
import '../usecases/set_default_address_use_case.dart';

abstract class RsProfileRepo {
  DataResponse<FetchFavoriteRestaurantsModel> fetchFavoriteRestaurants(
    FetchFavoriteRestaurantsParams params,
  );

  DataResponse<FetchAddressesModel> fetchAddresses(FetchAddressesParams params);

  DataResponse<FetchNotificationsPageModel> fetchNotifications(
    FetchNotificationsParams params,
  );

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

  DataResponse<ShowVoteModel> showVote(ShowVoteParams params);

  DataResponse<ActionResultModel> endVote(EndVoteParams params);

  Future<void> updatePersonalDetails(RsPersonalDetailsUpdateInput input);
}
