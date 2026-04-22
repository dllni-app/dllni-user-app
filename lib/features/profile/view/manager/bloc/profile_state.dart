part of 'profile_bloc.dart';

class ProfileState {
  BlocStatus? addShoppingListToCartStatus;
  AddShoppingListToCartModel? addShoppingListToCart;
  BlocStatus? shoppingListStatus;
  BlocStatus? createShoppingListStatus;
  BlocStatus? updateShoppingListStatus;
  GetShoppingListModel? shoppingList;
  BlocStatus? shoppingListDetailStatus;
  ShoppingListDetailModel? shoppingListDetail;
  String? quantityPatchError;
  final BlocStatus? addressesStatus;
  final List<AddressListItem> addresses;
  final String? defaultAddressId;
  final BlocStatus? setDefaultAddressStatus;

  final PaginationStateModel<FetchNotificationsModelDataItem> notificationsPagination;
  final BlocStatus? markAllNotificationsReadStatus;
  final String? notificationActionError;

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
  final BlocStatus? voteBallotStatus;
  final BlocStatus? endVoteStatus;
  final BlocStatus? activeVotesStatus;
  final List<VoteCreatedData> activeVotes;
  final BlocStatus? groupOrderRestaurantsStatus;
  final List<FetchDiscoverRestaurantsModelDataItem> groupOrderRestaurants;
  final FetchDiscoverRestaurantsModelDataItem? selectedGroupOrderRestaurant;
  final BlocStatus? createGroupOrderStatus;
  final GroupOrderActionModel? createGroupOrderResult;
  final BlocStatus? joinGroupOrderStatus;
  final GroupOrderActionModel? joinGroupOrderResult;
  final BlocStatus? activeGroupOrdersStatus;
  final List<GroupOrderDetailsModel> activeGroupOrders;
  final BlocStatus? groupOrderDetailsStatus;
  final GroupOrderDetailsModel? groupOrderDetails;
  final BlocStatus? groupOrderMenuStatus;
  final List<GroupOrderMenuSectionModel> groupOrderMenuSections;
  final List<GroupOrderMenuSectionItemModel> groupOrderMenuProducts;
  final BlocStatus? groupOrderActionStatus;
  final GroupOrderActionModel? groupOrderActionResult;

  final String? errorMessage;
  final String? actionMessage;

  ProfileState({
    this.addressesStatus,
    this.addresses = const <AddressListItem>[],
    this.defaultAddressId,
    this.setDefaultAddressStatus,
    this.notificationsPagination = const PaginationStateModel<FetchNotificationsModelDataItem>(perPage: 10),
    this.markAllNotificationsReadStatus,
    this.notificationActionError,
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
    this.voteBallotStatus,
    this.endVoteStatus,
    this.activeVotesStatus,
    this.activeVotes = const <VoteCreatedData>[],
    this.groupOrderRestaurantsStatus,
    this.groupOrderRestaurants = const <FetchDiscoverRestaurantsModelDataItem>[],
    this.selectedGroupOrderRestaurant,
    this.createGroupOrderStatus,
    this.createGroupOrderResult,
    this.joinGroupOrderStatus,
    this.joinGroupOrderResult,
    this.activeGroupOrdersStatus,
    this.activeGroupOrders = const <GroupOrderDetailsModel>[],
    this.groupOrderDetailsStatus,
    this.groupOrderDetails,
    this.groupOrderMenuStatus,
    this.groupOrderMenuSections = const <GroupOrderMenuSectionModel>[],
    this.groupOrderMenuProducts = const <GroupOrderMenuSectionItemModel>[],
    this.groupOrderActionStatus,
    this.groupOrderActionResult,
    this.errorMessage,
    this.actionMessage,
    this.shoppingList,
    this.shoppingListStatus,
    this.createShoppingListStatus,
    this.updateShoppingListStatus,
    this.shoppingListDetail,
    this.shoppingListDetailStatus,
    this.quantityPatchError,
    this.addShoppingListToCart,
    this.addShoppingListToCartStatus,
  });

  ProfileState copyWith({
    BlocStatus? addressesStatus,
    List<AddressListItem>? addresses,
    String? defaultAddressId,
    BlocStatus? setDefaultAddressStatus,
    PaginationStateModel<FetchNotificationsModelDataItem>? notificationsPagination,
    BlocStatus? markAllNotificationsReadStatus,
    bool clearMarkAllNotificationsReadStatus = false,
    String? notificationActionError,
    bool clearNotificationActionError = false,
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
    BlocStatus? voteBallotStatus,
    BlocStatus? endVoteStatus,
    BlocStatus? activeVotesStatus,
    List<VoteCreatedData>? activeVotes,
    BlocStatus? groupOrderRestaurantsStatus,
    List<FetchDiscoverRestaurantsModelDataItem>? groupOrderRestaurants,
    FetchDiscoverRestaurantsModelDataItem? selectedGroupOrderRestaurant,
    bool clearSelectedGroupOrderRestaurant = false,
    BlocStatus? createGroupOrderStatus,
    GroupOrderActionModel? createGroupOrderResult,
    BlocStatus? joinGroupOrderStatus,
    GroupOrderActionModel? joinGroupOrderResult,
    BlocStatus? activeGroupOrdersStatus,
    List<GroupOrderDetailsModel>? activeGroupOrders,
    BlocStatus? groupOrderDetailsStatus,
    GroupOrderDetailsModel? groupOrderDetails,
    BlocStatus? groupOrderMenuStatus,
    List<GroupOrderMenuSectionModel>? groupOrderMenuSections,
    List<GroupOrderMenuSectionItemModel>? groupOrderMenuProducts,
    BlocStatus? groupOrderActionStatus,
    GroupOrderActionModel? groupOrderActionResult,
    String? errorMessage,
    String? actionMessage,
    GetShoppingListModel? shoppingList,
    BlocStatus? shoppingListStatus,
    BlocStatus? createShoppingListStatus,
    BlocStatus? updateShoppingListStatus,
    ShoppingListDetailModel? shoppingListDetail,
    BlocStatus? shoppingListDetailStatus,
    String? quantityPatchError,
    bool clearQuantityPatchError = false,
    AddShoppingListToCartModel? addShoppingListToCart,
    BlocStatus? addShoppingListToCartStatus,
  }) => ProfileState(
    addressesStatus: addressesStatus ?? this.addressesStatus,
    addresses: addresses ?? this.addresses,
    defaultAddressId: defaultAddressId ?? this.defaultAddressId,
    setDefaultAddressStatus: setDefaultAddressStatus ?? this.setDefaultAddressStatus,
    notificationsPagination: notificationsPagination ?? this.notificationsPagination,
    markAllNotificationsReadStatus: clearMarkAllNotificationsReadStatus
        ? null
        : (markAllNotificationsReadStatus ?? this.markAllNotificationsReadStatus),
    notificationActionError: clearNotificationActionError
        ? null
        : (notificationActionError ?? this.notificationActionError),
    favoriteRestaurantsPagination: favoriteRestaurantsPagination ?? this.favoriteRestaurantsPagination,
    removeFavoriteRestaurantStatus: removeFavoriteRestaurantStatus ?? this.removeFavoriteRestaurantStatus,
    createVoteStatus: createVoteStatus ?? this.createVoteStatus,
    createdVote: createdVote ?? this.createdVote,
    voteSuggestionsStatus: voteSuggestionsStatus ?? this.voteSuggestionsStatus,
    voteSuggestions: voteSuggestions ?? this.voteSuggestions,
    createAddressStatus: createAddressStatus ?? this.createAddressStatus,
    updateAddressStatus: updateAddressStatus ?? this.updateAddressStatus,
    deleteAddressStatus: deleteAddressStatus ?? this.deleteAddressStatus,
    voteDetailsStatus: voteDetailsStatus ?? this.voteDetailsStatus,
    voteDetails: voteDetails ?? this.voteDetails,
    voteBallotStatus: voteBallotStatus ?? this.voteBallotStatus,
    endVoteStatus: endVoteStatus ?? this.endVoteStatus,
    activeVotesStatus: activeVotesStatus ?? this.activeVotesStatus,
    activeVotes: activeVotes ?? this.activeVotes,
    groupOrderRestaurantsStatus: groupOrderRestaurantsStatus ?? this.groupOrderRestaurantsStatus,
    groupOrderRestaurants: groupOrderRestaurants ?? this.groupOrderRestaurants,
    selectedGroupOrderRestaurant: clearSelectedGroupOrderRestaurant
        ? null
        : (selectedGroupOrderRestaurant ?? this.selectedGroupOrderRestaurant),
    createGroupOrderStatus: createGroupOrderStatus ?? this.createGroupOrderStatus,
    createGroupOrderResult: createGroupOrderResult ?? this.createGroupOrderResult,
    joinGroupOrderStatus: joinGroupOrderStatus ?? this.joinGroupOrderStatus,
    joinGroupOrderResult: joinGroupOrderResult ?? this.joinGroupOrderResult,
    activeGroupOrdersStatus: activeGroupOrdersStatus ?? this.activeGroupOrdersStatus,
    activeGroupOrders: activeGroupOrders ?? this.activeGroupOrders,
    groupOrderDetailsStatus: groupOrderDetailsStatus ?? this.groupOrderDetailsStatus,
    groupOrderDetails: groupOrderDetails ?? this.groupOrderDetails,
    groupOrderMenuStatus: groupOrderMenuStatus ?? this.groupOrderMenuStatus,
    groupOrderMenuSections: groupOrderMenuSections ?? this.groupOrderMenuSections,
    groupOrderMenuProducts: groupOrderMenuProducts ?? this.groupOrderMenuProducts,
    groupOrderActionStatus: groupOrderActionStatus ?? this.groupOrderActionStatus,
    groupOrderActionResult: groupOrderActionResult ?? this.groupOrderActionResult,
    errorMessage: errorMessage ?? this.errorMessage,
    actionMessage: actionMessage ?? this.actionMessage,
    shoppingList: shoppingList ?? this.shoppingList,
    shoppingListStatus: shoppingListStatus ?? this.shoppingListStatus,
    createShoppingListStatus: createShoppingListStatus ?? this.createShoppingListStatus,
    updateShoppingListStatus: updateShoppingListStatus ?? this.updateShoppingListStatus,
    shoppingListDetail: shoppingListDetail ?? this.shoppingListDetail,
    shoppingListDetailStatus: shoppingListDetailStatus ?? this.shoppingListDetailStatus,
    quantityPatchError: clearQuantityPatchError ? null : (quantityPatchError ?? this.quantityPatchError),
    addShoppingListToCart: addShoppingListToCart ?? this.addShoppingListToCart,
    addShoppingListToCartStatus: addShoppingListToCartStatus ?? this.addShoppingListToCartStatus,
  );

  BlocStatus get notificationsStatus => notificationsPagination.status;

  List<FetchNotificationsModelDataItem> get notifications => notificationsPagination.list;

  BlocStatus get favoriteRestaurantsStatus => favoriteRestaurantsPagination.status;

  List<FavoriteRestaurantModel> get favoriteRestaurants => favoriteRestaurantsPagination.list;
}
