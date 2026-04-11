part of 'home_bloc.dart';

class HomeState {
  BlocStatus? userOffersStatus;
  FetchUserOffersModel? userOffers;
  String? errorMessage;

  HomeState({
    this.userOffersStatus,
    this.userOffers,
    this.errorMessage,
  });

  HomeState copyWith({
    BlocStatus? userOffersStatus,
    FetchUserOffersModel? userOffers,
    String? errorMessage,
  }) =>
      HomeState(
        userOffersStatus: userOffersStatus ?? this.userOffersStatus,
        userOffers: userOffers ?? this.userOffers,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}
