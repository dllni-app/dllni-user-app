part of 'rs_offers_bloc.dart';

abstract class RsOffersEvent {}

class FetchRsOffersProductsEvent extends RsOffersEvent with EventWithReload {
  final bool loadMore;

  @override
  final bool isReload;

  FetchRsOffersProductsEvent({this.isReload = false, this.loadMore = false});
}
