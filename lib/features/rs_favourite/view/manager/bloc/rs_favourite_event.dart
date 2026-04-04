part of 'rs_favourite_bloc.dart';

abstract class RsFavouriteEvent {}

class FetchRsFavouritesEvent extends RsFavouriteEvent with EventWithReload {
  final FetchRsFavouritesParams params;
  final bool loadMore;

  @override
  final bool isReload;

  FetchRsFavouritesEvent({
    required this.params,
    this.isReload = false,
    this.loadMore = false,
  });
}
