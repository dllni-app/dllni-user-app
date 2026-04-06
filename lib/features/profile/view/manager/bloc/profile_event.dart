part of 'profile_bloc.dart';

abstract class ProfileEvent {}

class FetchAddressesEvent extends ProfileEvent {
  final FetchAddressesParams params;

  FetchAddressesEvent({required this.params});
}

class SetDefaultAddressEvent extends ProfileEvent {
  final int addressId;

  SetDefaultAddressEvent({required this.addressId});
}

class FetchNotificationsEvent extends ProfileEvent {
  final FetchNotificationsParams params;

  FetchNotificationsEvent({required this.params});
}

class MarkAllNotificationsReadEvent extends ProfileEvent {}

class FetchFavoriteRestaurantsEvent extends ProfileEvent {
  final FetchFavoriteRestaurantsParams params;

  FetchFavoriteRestaurantsEvent({required this.params});
}

class RemoveFavoriteRestaurantEvent extends ProfileEvent {
  final int restaurantId;

  RemoveFavoriteRestaurantEvent({required this.restaurantId});
}

class CreateVoteEvent extends ProfileEvent {
  final CreateVoteParams params;

  CreateVoteEvent({required this.params});
}

class ShowVoteEvent extends ProfileEvent {
  final int voteId;

  ShowVoteEvent({required this.voteId});
}

class EndVoteEvent extends ProfileEvent {
  final int voteId;

  EndVoteEvent({required this.voteId});
}
