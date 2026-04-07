part of 'sm_home_bloc.dart';

abstract class SmHomeEvent {}

class GetFeaturedOffersEvent extends SmHomeEvent {
  final GetFeaturedOffersParams params;

  GetFeaturedOffersEvent({required this.params});
}

class GetNearbyStoresEvent extends SmHomeEvent {
  final GetNearbyStoresParams params;

  GetNearbyStoresEvent({required this.params});
}

class ChangeStoreFavoriteEvent extends SmHomeEvent {
  final ChangeStoreFavoriteParams params;

  ChangeStoreFavoriteEvent({required this.params});
}
