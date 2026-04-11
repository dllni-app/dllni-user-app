part of 'home_bloc.dart';

abstract class HomeEvent {}

class FetchUserOffersEvent extends HomeEvent {
  final FetchUserOffersParams params;

  FetchUserOffersEvent({required this.params});
}
