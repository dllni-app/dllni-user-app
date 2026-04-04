part of 'rs_profile_bloc.dart';

abstract class RsProfileEvent {}

class FetchAddressesEvent extends RsProfileEvent {
  final FetchAddressesParams params;

  FetchAddressesEvent({required this.params});
}

class SetDefaultAddressEvent extends RsProfileEvent {
  final int addressId;

  SetDefaultAddressEvent({required this.addressId});
}

class FetchNotificationsEvent extends RsProfileEvent {
  final FetchNotificationsParams params;

  FetchNotificationsEvent({required this.params});
}

class MarkAllNotificationsReadEvent extends RsProfileEvent {}

class FetchFavoriteRestaurantsEvent extends RsProfileEvent {
  final FetchFavoriteRestaurantsParams params;

  FetchFavoriteRestaurantsEvent({required this.params});
}

class RemoveFavoriteRestaurantEvent extends RsProfileEvent {
  final int restaurantId;

  RemoveFavoriteRestaurantEvent({required this.restaurantId});
}

class CreateVoteEvent extends RsProfileEvent {
  final CreateVoteParams params;

  CreateVoteEvent({required this.params});
}

class ShowVoteEvent extends RsProfileEvent {
  final int voteId;

  ShowVoteEvent({required this.voteId});
}

class EndVoteEvent extends RsProfileEvent {
  final int voteId;

  EndVoteEvent({required this.voteId});
}
