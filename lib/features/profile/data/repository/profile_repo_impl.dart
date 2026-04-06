import 'package:common_package/common_package.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/fetch_addresses_use_case.dart';
import '../../domain/usecases/fetch_favorite_restaurants_use_case.dart';
import '../../domain/usecases/fetch_notifications_use_case.dart';
import '../../domain/usecases/create_vote_use_case.dart';
import '../../domain/usecases/show_vote_use_case.dart';
import '../../domain/usecases/end_vote_use_case.dart';
import '../../domain/usecases/add_favorite_restaurant_use_case.dart';
import '../../domain/usecases/remove_favorite_restaurant_use_case.dart';
import '../../domain/usecases/set_default_address_use_case.dart';
import '../models/profile_api_models.dart';
import '../source/profile_remote_data_source.dart';
import '../../domain/models/personal_details_update_input.dart';
import '../../domain/repository/profile_repo.dart';

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
  DataResponse<FetchNotificationsPageModel> fetchNotifications(
    FetchNotificationsParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => profileRemoteDataSource.fetchNotifications(params),
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
  Future<void> updatePersonalDetails(PersonalDetailsUpdateInput input) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
  }
}
