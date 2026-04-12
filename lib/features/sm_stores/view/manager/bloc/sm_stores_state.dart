part of 'sm_stores_bloc.dart';

class SmStoresState {
  PaginationStateModel<GetCompareProductsModelDataItem>? compareProducts;
  final BlocStatus storeDetailsStatus;
  final SupermarketStoreDetailsStore? store;

  final BlocStatus productDetailsStatus;
  final SupermarketProductDetailsProduct? productDetails;
  final BlocStatus addToCartStatus;
  final String? addToCartMessage;
  final String? addToCartErrorMessage;

  final String? errorMessage;

  final BlocStatus shoppingListsStatus;
  final List<ShoppingListSummaryModel> shoppingLists;
  final String? shoppingListsErrorMessage;

  SmStoresState({
    this.storeDetailsStatus = BlocStatus.init,
    this.store,
    this.productDetailsStatus = BlocStatus.init,
    this.productDetails,
    this.addToCartStatus = BlocStatus.init,
    this.addToCartMessage,
    this.addToCartErrorMessage,
    this.errorMessage,
    this.compareProducts = const PaginationStateModel(perPage: 10),
    this.shoppingListsStatus = BlocStatus.init,
    this.shoppingLists = const <ShoppingListSummaryModel>[],
    this.shoppingListsErrorMessage,
  });

  /// Clears product details and sets loading (copyWith cannot null [productDetails]).
  SmStoresState toProductDetailsLoading() {
    return SmStoresState(
      storeDetailsStatus: storeDetailsStatus,
      store: store,
      productDetailsStatus: BlocStatus.loading,
      productDetails: null,
      addToCartStatus: addToCartStatus,
      addToCartMessage: addToCartMessage,
      addToCartErrorMessage: addToCartErrorMessage,
      errorMessage: null,
      compareProducts: compareProducts,
      shoppingListsStatus: shoppingListsStatus,
      shoppingLists: shoppingLists,
      shoppingListsErrorMessage: shoppingListsErrorMessage,
    );
  }

  SmStoresState copyWith({
    BlocStatus? storeDetailsStatus,
    SupermarketStoreDetailsStore? store,
    BlocStatus? productDetailsStatus,
    SupermarketProductDetailsProduct? productDetails,
    BlocStatus? addToCartStatus,
    String? addToCartMessage,
    String? addToCartErrorMessage,
    bool clearAddToCartMessage = false,
    bool clearAddToCartError = false,
    String? errorMessage,
    PaginationStateModel<GetCompareProductsModelDataItem>? compareProducts,
    BlocStatus? shoppingListsStatus,
    List<ShoppingListSummaryModel>? shoppingLists,
    String? shoppingListsErrorMessage,
    bool clearShoppingListsError = false,
  }) {
    return SmStoresState(
      storeDetailsStatus: storeDetailsStatus ?? this.storeDetailsStatus,
      store: store ?? this.store,
      productDetailsStatus: productDetailsStatus ?? this.productDetailsStatus,
      productDetails: productDetails ?? this.productDetails,
      addToCartStatus: addToCartStatus ?? this.addToCartStatus,
      addToCartMessage:
          clearAddToCartMessage ? null : (addToCartMessage ?? this.addToCartMessage),
      addToCartErrorMessage: clearAddToCartError
          ? null
          : (addToCartErrorMessage ?? this.addToCartErrorMessage),
      errorMessage: errorMessage ?? this.errorMessage,
      compareProducts: compareProducts ?? this.compareProducts,
      shoppingListsStatus: shoppingListsStatus ?? this.shoppingListsStatus,
      shoppingLists: shoppingLists ?? this.shoppingLists,
      shoppingListsErrorMessage: clearShoppingListsError
          ? null
          : (shoppingListsErrorMessage ?? this.shoppingListsErrorMessage),
    );
  }
}
