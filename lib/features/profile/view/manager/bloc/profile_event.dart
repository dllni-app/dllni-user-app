part of 'profile_bloc.dart';

abstract class ProfileEvent {}

class FetchAddressesEvent extends ProfileEvent {
  final FetchAddressesParams params;

  FetchAddressesEvent({required this.params});
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

class CreateAddressEvent extends ProfileEvent {
  final CreateAddressParams params;

  CreateAddressEvent({required this.params});
}

class UpdateAddressEvent extends ProfileEvent {
  final UpdateAddressParams params;

  UpdateAddressEvent({required this.params});
}

class DeleteAddressEvent extends ProfileEvent {
  final int addressId;
  final BuildContext context;

  DeleteAddressEvent({required this.addressId, required this.context});
}

class ShowVoteEvent extends ProfileEvent {
  final int voteId;

  ShowVoteEvent({required this.voteId});
}

class EndVoteEvent extends ProfileEvent {
  final int voteId;

  EndVoteEvent({required this.voteId});
}

class FetchActiveVotesEvent extends ProfileEvent {
  final FetchActiveVotesParams params;

  FetchActiveVotesEvent({required this.params});
}
