part of 'home_bloc.dart';

class HomeState {
  PaginationStateModel<UserOfferItem> userOffers;
  String? errorMessage;

  HomeState({
    this.userOffers = const PaginationStateModel<UserOfferItem>(perPage: 10),
    this.errorMessage,
  });

  HomeState copyWith({
    PaginationStateModel<UserOfferItem>? userOffers,
    String? errorMessage,
  }) =>
      HomeState(
        userOffers: userOffers ?? this.userOffers,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  BlocStatus get userOffersStatus => userOffers.status;
}
