import 'package:common_package/helpers/error_handler.dart';
import 'package:common_package/helpers/typedef.dart';
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
import '../models/rs_profile_api_models.dart';
import '../source/rs_profile_remote_data_source.dart';
import '../../domain/models/rs_personal_details_update_input.dart';
import '../../domain/repository/rs_profile_repo.dart';

@LazySingleton(as: RsProfileRepo)
class RsProfileRepoImpl with HandlingException implements RsProfileRepo {
  final RsProfileRemoteDataSource rsProfileRemoteDataSource;

  RsProfileRepoImpl({required this.rsProfileRemoteDataSource});

  @override
  DataResponse<FetchFavoriteRestaurantsModel> fetchFavoriteRestaurants(
    FetchFavoriteRestaurantsParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => rsProfileRemoteDataSource.fetchFavoriteRestaurants(params),
    );
  }

  @override
  DataResponse<FetchAddressesModel> fetchAddresses(
    FetchAddressesParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => rsProfileRemoteDataSource.fetchAddresses(params),
    );
  }

  @override
  DataResponse<FetchNotificationsPageModel> fetchNotifications(
    FetchNotificationsParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => rsProfileRemoteDataSource.fetchNotifications(params),
    );
  }

  @override
  DataResponse<ActionResultModel> removeFavoriteRestaurant(
    RemoveFavoriteRestaurantParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => rsProfileRemoteDataSource.removeFavoriteRestaurant(params),
    );
  }

  @override
  DataResponse<ActionResultModel> addFavoriteRestaurant(
    AddFavoriteRestaurantParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => rsProfileRemoteDataSource.addFavoriteRestaurant(params),
    );
  }

  @override
  DataResponse<ActionResultModel> setDefaultAddress(
    SetDefaultAddressParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => rsProfileRemoteDataSource.setDefaultAddress(params),
    );
  }

  @override
  DataResponse<CreateVoteModel> createVote(CreateVoteParams params) {
    return wrapHandlingException(
      tryCall: () => rsProfileRemoteDataSource.createVote(params),
    );
  }

  @override
  DataResponse<ShowVoteModel> showVote(ShowVoteParams params) {
    return wrapHandlingException(
      tryCall: () => rsProfileRemoteDataSource.showVote(params),
    );
  }

  @override
  DataResponse<ActionResultModel> endVote(EndVoteParams params) {
    return wrapHandlingException(
      tryCall: () => rsProfileRemoteDataSource.endVote(params),
    );
  }

  @override
  Future<void> updatePersonalDetails(RsPersonalDetailsUpdateInput input) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
  }
}
