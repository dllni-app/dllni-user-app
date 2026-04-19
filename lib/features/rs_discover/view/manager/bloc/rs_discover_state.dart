part of 'rs_discover_bloc.dart';

enum RsDiscoverSearchMode { smart, restaurant, meal }

class RsDiscoverState {
  final PaginationStateModel<FetchDiscoverRestaurantsModelDataItem> restaurants;
  final PaginationStateModel<FetchRestaurantProductsSearchModelDataItem>
  products;
  final int selectedTabIndex;
  final RsDiscoverSearchMode activeSearchMode;
  final String searchQuery;
  final String productSearchQuery;
  final int totalCount;
  final FetchRestaurantProductDetailsModel? productDetails;
  final bool isLoadingProductDetails;
  final String productDetailsErrorMessage;

  RsDiscoverState({
    this.restaurants = const PaginationStateModel(perPage: 10),
    this.products = const PaginationStateModel(perPage: 10),
    this.selectedTabIndex = 0,
    this.activeSearchMode = RsDiscoverSearchMode.restaurant,
    this.searchQuery = '',
    this.productSearchQuery = '',
    this.totalCount = 0,
    this.productDetails,
    this.isLoadingProductDetails = false,
    this.productDetailsErrorMessage = '',
  });

  RsDiscoverState copyWith({
    PaginationStateModel<FetchDiscoverRestaurantsModelDataItem>? restaurants,
    PaginationStateModel<FetchRestaurantProductsSearchModelDataItem>? products,
    int? selectedTabIndex,
    RsDiscoverSearchMode? activeSearchMode,
    String? searchQuery,
    String? productSearchQuery,
    int? totalCount,
    FetchRestaurantProductDetailsModel? productDetails,
    bool clearProductDetails = false,
    bool? isLoadingProductDetails,
    String? productDetailsErrorMessage,
  }) {
    return RsDiscoverState(
      restaurants: restaurants ?? this.restaurants,
      products: products ?? this.products,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      activeSearchMode: activeSearchMode ?? this.activeSearchMode,
      searchQuery: searchQuery ?? this.searchQuery,
      productSearchQuery: productSearchQuery ?? this.productSearchQuery,
      totalCount: totalCount ?? this.totalCount,
      productDetails: clearProductDetails
          ? null
          : (productDetails ?? this.productDetails),
      isLoadingProductDetails:
          isLoadingProductDetails ?? this.isLoadingProductDetails,
      productDetailsErrorMessage:
          productDetailsErrorMessage ?? this.productDetailsErrorMessage,
    );
  }
}
