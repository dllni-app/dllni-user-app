part of 'rs_discover_bloc.dart';

abstract class RsDiscoverEvent {}

class FetchDiscoverRestaurantsEvent extends RsDiscoverEvent with EventWithReload {
  @override
  final bool isReload;

  final bool loadMore;

  FetchDiscoverRestaurantsEvent({this.isReload = false, this.loadMore = false});
}

class DiscoverTabChangedEvent extends RsDiscoverEvent {
  final int tabIndex;

  DiscoverTabChangedEvent(this.tabIndex);
}

class DiscoverSearchQueryChangedEvent extends RsDiscoverEvent {
  final String query;

  DiscoverSearchQueryChangedEvent(this.query);
}

class FetchRestaurantProductDetailsEvent extends RsDiscoverEvent {
  final int productId;

  FetchRestaurantProductDetailsEvent({required this.productId});
}
