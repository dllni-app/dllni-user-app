part of 'rs_offers_bloc.dart';

class RsOffersState {
  final PaginationStateModel<FetchRsOffersProductsModelDataItem> products;
  final String? errorMessage;

  RsOffersState({
    this.errorMessage,
    this.products = const PaginationStateModel(perPage: 10),
  });

  RsOffersState copyWith({
    PaginationStateModel<FetchRsOffersProductsModelDataItem>? products,
    String? errorMessage,
  }) =>
      RsOffersState(
        products: products ?? this.products,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}
