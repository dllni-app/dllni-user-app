part of 'sm_discover_bloc.dart';

abstract class SmDiscoverEvent {}

class BrowseStoresEvent extends SmDiscoverEvent with EventWithReload {
  final BrowseStoresParams params;

  @override
  final bool isReload;

  BrowseStoresEvent({required this.params, this.isReload = false});
}

class BrowseProductsEvent extends SmDiscoverEvent with EventWithReload {
  final BrowseProductsParams params;

  @override
  final bool isReload;

  BrowseProductsEvent({required this.params, this.isReload = false});
}

class ChangeStoreFavoriteEvent extends SmDiscoverEvent {
  final ChangeStoreFavoriteParams params;

  ChangeStoreFavoriteEvent({required this.params});
}

class ChangeProductFavoriteEvent extends SmDiscoverEvent {
  final ChangeProductFavoriteParams params;

  ChangeProductFavoriteEvent({required this.params});
}
