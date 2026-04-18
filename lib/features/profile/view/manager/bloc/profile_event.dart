part of 'profile_bloc.dart';

class AddShoppingListToCartEvent extends ProfileEvent {
  final AddShoppingListToCartParams params;

  AddShoppingListToCartEvent({required this.params});
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

class CreateVoteEvent extends ProfileEvent {
  final CreateVoteParams params;

  CreateVoteEvent({required this.params});
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

class FetchActiveVotesEvent extends ProfileEvent {
  final FetchActiveVotesParams params;

  FetchActiveVotesEvent({required this.params});
}

class FetchAddressesEvent extends ProfileEvent {
  final FetchAddressesParams params;

  FetchAddressesEvent({required this.params});
}

class FetchFavoriteRestaurantsEvent extends ProfileEvent {
  final FetchFavoriteRestaurantsParams params;

  FetchFavoriteRestaurantsEvent({required this.params});
}

class FetchNotificationsEvent extends ProfileEvent {
  final FetchNotificationsParams params;

  FetchNotificationsEvent({required this.params});
}

class FetchVoteSuggestionsEvent extends ProfileEvent {
  final String searchQuery;

  FetchVoteSuggestionsEvent({required this.searchQuery});
}

class GetShoppingListDetailEvent extends ProfileEvent {
  final FetchShoppingListDetailParams params;

  GetShoppingListDetailEvent({required this.params});
}

class GetShoppingListEvent extends ProfileEvent {
  final GetShoppingListParams params;

  GetShoppingListEvent({required this.params});
}

class MarkAllNotificationsReadEvent extends ProfileEvent {}

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

class RemoveFavoriteRestaurantEvent extends ProfileEvent {
  final int restaurantId;

  RemoveFavoriteRestaurantEvent({required this.restaurantId});
}

class SetDefaultAddressEvent extends ProfileEvent {
  final int addressId;
  final BuildContext context;

  SetDefaultAddressEvent({required this.addressId, required this.context});
}

class ShowVoteEvent extends ProfileEvent {
  final int voteId;

  ShowVoteEvent({required this.voteId});
}

class UpdateAddressEvent extends ProfileEvent {
  final UpdateAddressParams params;

  UpdateAddressEvent({required this.params});
}
