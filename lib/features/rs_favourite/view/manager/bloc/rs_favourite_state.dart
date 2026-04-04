part of 'rs_favourite_bloc.dart';

class RsFavouriteState {
  final PaginationStateModel<FetchRsFavouritesModelDataItem> rsFavourites;
  final String? errorMessage;

  RsFavouriteState({
    this.errorMessage,
    this.rsFavourites = const PaginationStateModel(perPage: 10),
  });

  RsFavouriteState copyWith({
    String? errorMessage,
    PaginationStateModel<FetchRsFavouritesModelDataItem>? rsFavourites,
  }) =>
      RsFavouriteState(
        errorMessage: errorMessage ?? this.errorMessage,
        rsFavourites: rsFavourites ?? this.rsFavourites,
      );
}
