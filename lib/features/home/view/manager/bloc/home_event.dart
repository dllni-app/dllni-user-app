part of 'home_bloc.dart';

abstract class HomeEvent {}

class FetchUserOffersEvent extends HomeEvent with EventWithReload {
  final FetchUserOffersParams params;
  final bool loadMore;
  @override
  final bool isReload;

  FetchUserOffersEvent({
    required this.params,
    this.loadMore = false,
    this.isReload = false,
  });
}
