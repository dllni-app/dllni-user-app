part of 'profile_bloc.dart';

class ProfileState {
  final BlocStatus? addressesStatus;
  final List<AddressListItem> addresses;
  final String? defaultAddressId;
  final BlocStatus? setDefaultAddressStatus;

  final PaginationStateModel<FetchNotificationsModelDataItem> notificationsPagination;

  final PaginationStateModel<FavoriteRestaurantModel> favoriteRestaurantsPagination;
  final BlocStatus? removeFavoriteRestaurantStatus;

  final BlocStatus? createVoteStatus;
  final CreateVoteModel? createdVote;
  final BlocStatus? voteSuggestionsStatus;
  final VoteSuggestionsModel? voteSuggestions;
  final BlocStatus? createAddressStatus;
  final BlocStatus? updateAddressStatus;
  final BlocStatus? deleteAddressStatus;

  final BlocStatus? voteDetailsStatus;
  final ShowVoteModel? voteDetails;
  final BlocStatus? endVoteStatus;
  final BlocStatus? activeVotesStatus;
  final List<VoteCreatedData> activeVotes;

  final String? errorMessage;
  final String? actionMessage;

  ProfileState({
    this.addressesStatus,
    this.addresses = const <AddressListItem>[],
    this.defaultAddressId,
    this.setDefaultAddressStatus,
    this.notificationsPagination = const PaginationStateModel<FetchNotificationsModelDataItem>(perPage: 10),
    this.favoriteRestaurantsPagination = const PaginationStateModel<FavoriteRestaurantModel>(perPage: 20),
    this.removeFavoriteRestaurantStatus,
    this.createVoteStatus,
    this.createdVote,
    this.voteSuggestionsStatus,
    this.voteSuggestions,
    this.createAddressStatus,
    this.updateAddressStatus,
    this.deleteAddressStatus,
    this.voteDetailsStatus,
    this.voteDetails,
    this.endVoteStatus,
    this.activeVotesStatus,
    this.activeVotes = const <VoteCreatedData>[],
    this.errorMessage,
    this.actionMessage,
  });

  ProfileState copyWith({
    BlocStatus? addressesStatus,
    List<AddressListItem>? addresses,
    String? defaultAddressId,
    BlocStatus? setDefaultAddressStatus,
    PaginationStateModel<FetchNotificationsModelDataItem>? notificationsPagination,
    PaginationStateModel<FavoriteRestaurantModel>? favoriteRestaurantsPagination,
    BlocStatus? removeFavoriteRestaurantStatus,
    BlocStatus? createVoteStatus,
    CreateVoteModel? createdVote,
    BlocStatus? voteSuggestionsStatus,
    VoteSuggestionsModel? voteSuggestions,
    BlocStatus? createAddressStatus,
    BlocStatus? updateAddressStatus,
    BlocStatus? deleteAddressStatus,
    BlocStatus? voteDetailsStatus,
    ShowVoteModel? voteDetails,
    BlocStatus? endVoteStatus,
    BlocStatus? activeVotesStatus,
    List<VoteCreatedData>? activeVotes,
    String? errorMessage,
    String? actionMessage,
  }) => ProfileState(
    addressesStatus: addressesStatus ?? this.addressesStatus,
    addresses: addresses ?? this.addresses,
    defaultAddressId: defaultAddressId ?? this.defaultAddressId,
    setDefaultAddressStatus:
        setDefaultAddressStatus ?? this.setDefaultAddressStatus,
    notificationsPagination: notificationsPagination ?? this.notificationsPagination,
    favoriteRestaurantsPagination: favoriteRestaurantsPagination ?? this.favoriteRestaurantsPagination,
    removeFavoriteRestaurantStatus:
        removeFavoriteRestaurantStatus ?? this.removeFavoriteRestaurantStatus,
    createVoteStatus: createVoteStatus ?? this.createVoteStatus,
    createdVote: createdVote ?? this.createdVote,
    voteSuggestionsStatus: voteSuggestionsStatus ?? this.voteSuggestionsStatus,
    voteSuggestions: voteSuggestions ?? this.voteSuggestions,
    createAddressStatus: createAddressStatus ?? this.createAddressStatus,
    updateAddressStatus: updateAddressStatus ?? this.updateAddressStatus,
    deleteAddressStatus: deleteAddressStatus ?? this.deleteAddressStatus,
    voteDetailsStatus: voteDetailsStatus ?? this.voteDetailsStatus,
    voteDetails: voteDetails ?? this.voteDetails,
    endVoteStatus: endVoteStatus ?? this.endVoteStatus,
    activeVotesStatus: activeVotesStatus ?? this.activeVotesStatus,
    activeVotes: activeVotes ?? this.activeVotes,
    errorMessage: errorMessage ?? this.errorMessage,
    actionMessage: actionMessage ?? this.actionMessage,
  );

  BlocStatus get notificationsStatus => notificationsPagination.status;
  List<FetchNotificationsModelDataItem> get notifications => notificationsPagination.list;
  BlocStatus get favoriteRestaurantsStatus => favoriteRestaurantsPagination.status;
  List<FavoriteRestaurantModel> get favoriteRestaurants => favoriteRestaurantsPagination.list;
}
