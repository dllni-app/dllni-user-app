part of 'rs_profile_bloc.dart';

class RsProfileState {
  final BlocStatus? addressesStatus;
  final List<RsAddressListItem> addresses;
  final String? defaultAddressId;
  final BlocStatus? setDefaultAddressStatus;

  final BlocStatus? notificationsStatus;
  final List<FetchNotificationsModelDataItem> notifications;

  final BlocStatus? favoriteRestaurantsStatus;
  final List<FavoriteRestaurantModel> favoriteRestaurants;
  final BlocStatus? removeFavoriteRestaurantStatus;

  final BlocStatus? createVoteStatus;
  final CreateVoteModel? createdVote;

  final BlocStatus? voteDetailsStatus;
  final ShowVoteModel? voteDetails;
  final BlocStatus? endVoteStatus;

  final String? errorMessage;
  final String? actionMessage;

  RsProfileState({
    this.addressesStatus,
    this.addresses = const <RsAddressListItem>[],
    this.defaultAddressId,
    this.setDefaultAddressStatus,
    this.notificationsStatus,
    this.notifications = const <FetchNotificationsModelDataItem>[],
    this.favoriteRestaurantsStatus,
    this.favoriteRestaurants = const <FavoriteRestaurantModel>[],
    this.removeFavoriteRestaurantStatus,
    this.createVoteStatus,
    this.createdVote,
    this.voteDetailsStatus,
    this.voteDetails,
    this.endVoteStatus,
    this.errorMessage,
    this.actionMessage,
  });

  RsProfileState copyWith({
    BlocStatus? addressesStatus,
    List<RsAddressListItem>? addresses,
    String? defaultAddressId,
    BlocStatus? setDefaultAddressStatus,
    BlocStatus? notificationsStatus,
    List<FetchNotificationsModelDataItem>? notifications,
    BlocStatus? favoriteRestaurantsStatus,
    List<FavoriteRestaurantModel>? favoriteRestaurants,
    BlocStatus? removeFavoriteRestaurantStatus,
    BlocStatus? createVoteStatus,
    CreateVoteModel? createdVote,
    BlocStatus? voteDetailsStatus,
    ShowVoteModel? voteDetails,
    BlocStatus? endVoteStatus,
    String? errorMessage,
    String? actionMessage,
  }) => RsProfileState(
    addressesStatus: addressesStatus ?? this.addressesStatus,
    addresses: addresses ?? this.addresses,
    defaultAddressId: defaultAddressId ?? this.defaultAddressId,
    setDefaultAddressStatus:
        setDefaultAddressStatus ?? this.setDefaultAddressStatus,
    notificationsStatus: notificationsStatus ?? this.notificationsStatus,
    notifications: notifications ?? this.notifications,
    favoriteRestaurantsStatus:
        favoriteRestaurantsStatus ?? this.favoriteRestaurantsStatus,
    favoriteRestaurants: favoriteRestaurants ?? this.favoriteRestaurants,
    removeFavoriteRestaurantStatus:
        removeFavoriteRestaurantStatus ?? this.removeFavoriteRestaurantStatus,
    createVoteStatus: createVoteStatus ?? this.createVoteStatus,
    createdVote: createdVote ?? this.createdVote,
    voteDetailsStatus: voteDetailsStatus ?? this.voteDetailsStatus,
    voteDetails: voteDetails ?? this.voteDetails,
    endVoteStatus: endVoteStatus ?? this.endVoteStatus,
    errorMessage: errorMessage ?? this.errorMessage,
    actionMessage: actionMessage ?? this.actionMessage,
  );
}
