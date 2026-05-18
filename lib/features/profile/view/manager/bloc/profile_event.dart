part of 'profile_bloc.dart';

class AddShoppingListToCartEvent extends ProfileEvent {
  final AddShoppingListToCartParams params;

  AddShoppingListToCartEvent({required this.params});
}

class SetDefaultAddressEvent extends ProfileEvent {
  final int addressId;
  final BuildContext context;

  SetDefaultAddressEvent({required this.addressId, required this.context});
}

class FetchNotificationsEvent extends ProfileEvent with EventWithReload {
  final FetchNotificationsParams params;
  final bool loadMore;
  @override
  final bool isReload;

  FetchNotificationsEvent({
    required this.params,
    this.loadMore = false,
    this.isReload = false,
  });
}

class MarkAllNotificationsReadEvent extends ProfileEvent {}

class MarkNotificationReadEvent extends ProfileEvent {
  final String id;

  MarkNotificationReadEvent({required this.id});
}

class FetchFavoriteRestaurantsEvent extends ProfileEvent with EventWithReload {
  final FetchFavoriteRestaurantsParams params;
  final bool loadMore;
  @override
  final bool isReload;

  FetchFavoriteRestaurantsEvent({
    required this.params,
    this.loadMore = false,
    this.isReload = false,
  });
}

class RemoveFavoriteRestaurantEvent extends ProfileEvent {
  final int restaurantId;

  RemoveFavoriteRestaurantEvent({required this.restaurantId});
}

class CreateVoteEvent extends ProfileEvent {
  final CreateVoteParams params;

  CreateVoteEvent({required this.params});
}

class FetchVoteSuggestionsEvent extends ProfileEvent {
  final String searchQuery;

  FetchVoteSuggestionsEvent({required this.searchQuery});
}

class ClearShoppingListQuantityPatchErrorEvent extends ProfileEvent {}

class CreateAddressEvent extends ProfileEvent {
  final CreateAddressParams params;

  CreateAddressEvent({required this.params});
}

class CreateShoppingListEvent extends ProfileEvent {
  final CreateShoppingListParams params;

  CreateShoppingListEvent({required this.params});
}

class UpdateShoppingListEvent extends ProfileEvent {
  final UpdateShoppingListParams params;

  UpdateShoppingListEvent({required this.params});
}

class DeleteAddressEvent extends ProfileEvent {
  final int addressId;
  final BuildContext context;

  DeleteAddressEvent({required this.addressId, required this.context});
}

class DeleteShoppingListItemEvent extends ProfileEvent {
  final int shoppingListId;
  final int itemId;
  final BuildContext context;

  DeleteShoppingListItemEvent({
    required this.shoppingListId,
    required this.itemId,
    required this.context,
  });
}

class EndVoteEvent extends ProfileEvent {
  final int voteId;

  EndVoteEvent({required this.voteId});
}

class SubmitVoteBallotEvent extends ProfileEvent {
  final int voteId;
  final int optionId;

  SubmitVoteBallotEvent({required this.voteId, required this.optionId});
}

class FetchActiveVotesEvent extends ProfileEvent {
  final FetchActiveVotesParams params;

  FetchActiveVotesEvent({required this.params});
}

class FetchAddressesEvent extends ProfileEvent {
  final FetchAddressesParams params;

  FetchAddressesEvent({required this.params});
}

class GetShoppingListDetailEvent extends ProfileEvent {
  final FetchShoppingListDetailParams params;

  GetShoppingListDetailEvent({required this.params});
}

class GetShoppingListEvent extends ProfileEvent {
  final GetShoppingListParams params;

  GetShoppingListEvent({required this.params});
}

class PatchShoppingListItemQuantityEvent extends ProfileEvent {
  final int shoppingListId;
  final int itemId;
  final num quantity;

  PatchShoppingListItemQuantityEvent({
    required this.shoppingListId,
    required this.itemId,
    required this.quantity,
  });
}

abstract class ProfileEvent {}

class ShowVoteEvent extends ProfileEvent {
  final int voteId;

  ShowVoteEvent({required this.voteId});
}

class UpdateAddressEvent extends ProfileEvent {
  final UpdateAddressParams params;

  UpdateAddressEvent({required this.params});
}

class FetchGroupOrderRestaurantsEvent extends ProfileEvent {
  final String searchQuery;

  FetchGroupOrderRestaurantsEvent({this.searchQuery = ''});
}

class SelectGroupOrderRestaurantEvent extends ProfileEvent {
  final FetchDiscoverRestaurantsModelDataItem restaurant;

  SelectGroupOrderRestaurantEvent({required this.restaurant});
}

class CreateGroupOrderEvent extends ProfileEvent {
  final CreateGroupOrderParams params;

  CreateGroupOrderEvent({required this.params});
}

class JoinGroupOrderEvent extends ProfileEvent {
  final JoinGroupOrderParams params;

  JoinGroupOrderEvent({required this.params});
}

class FetchActiveGroupOrdersEvent extends ProfileEvent {
  final FetchActiveGroupOrdersParams params;

  FetchActiveGroupOrdersEvent({required this.params});
}

class ShowGroupOrderEvent extends ProfileEvent {
  final ShowGroupOrderParams params;
  final bool skipMenuFetch;
  final String? fallbackReason;

  ShowGroupOrderEvent({
    required this.params,
    this.skipMenuFetch = false,
    this.fallbackReason,
  });
}

class HydrateGroupOrderFromPayloadEvent extends ProfileEvent {
  final Map<String, dynamic> payload;

  HydrateGroupOrderFromPayloadEvent({required this.payload});
}

class AddGroupOrderItemEvent extends ProfileEvent {
  final AddGroupOrderItemParams params;

  AddGroupOrderItemEvent({required this.params});
}

class UpdateGroupOrderItemEvent extends ProfileEvent {
  final UpdateGroupOrderItemParams params;

  UpdateGroupOrderItemEvent({required this.params});
}

class DeleteGroupOrderItemEvent extends ProfileEvent {
  final DeleteGroupOrderItemParams params;

  DeleteGroupOrderItemEvent({required this.params});
}

class SubmitGroupOrderEvent extends ProfileEvent {
  final SubmitGroupOrderParams params;

  SubmitGroupOrderEvent({required this.params});
}

class UnsubmitGroupOrderEvent extends ProfileEvent {
  final UnsubmitGroupOrderParams params;

  UnsubmitGroupOrderEvent({required this.params});
}

class CancelGroupOrderEvent extends ProfileEvent {
  final CancelGroupOrderParams params;

  CancelGroupOrderEvent({required this.params});
}

class PlaceGroupOrderEvent extends ProfileEvent {
  final PlaceGroupOrderParams params;

  PlaceGroupOrderEvent({required this.params});
}
