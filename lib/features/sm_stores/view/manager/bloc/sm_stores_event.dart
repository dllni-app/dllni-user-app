part of 'sm_stores_bloc.dart';

class LoadSupermarketStoreDetailsEvent extends SmStoresEvent {
  final int storeId;

  LoadSupermarketStoreDetailsEvent({required this.storeId});
}

class LoadSupermarketProductDetailsEvent extends SmStoresEvent {
  final int productId;

  LoadSupermarketProductDetailsEvent({required this.productId});
}

abstract class SmStoresEvent {}

class GetCompareProductsEvent extends SmStoresEvent with EventWithReload {
  final GetCompareProductsParams params;

  @override
  final bool isReload;

  GetCompareProductsEvent({required this.params, this.isReload = false});
}
