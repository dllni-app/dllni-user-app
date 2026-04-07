part of 'rs_discover_bloc.dart';

class RsDiscoverState {
  final PaginationStateModel<FetchDiscoverRestaurantsModelDataItem> restaurants;
  final int selectedTabIndex;
  final String searchQuery;
  final int totalCount;
  final FetchRestaurantProductDetailsModel? productDetails;
  final bool isLoadingProductDetails;
  final String productDetailsErrorMessage;

  RsDiscoverState({
    this.restaurants = const PaginationStateModel(perPage: 10),
    this.selectedTabIndex = 0,
    this.searchQuery = '',
    this.totalCount = 0,
    this.productDetails,
    this.isLoadingProductDetails = false,
    this.productDetailsErrorMessage = '',
  });

  RsDiscoverState copyWith({
    PaginationStateModel<FetchDiscoverRestaurantsModelDataItem>? restaurants,
    int? selectedTabIndex,
    String? searchQuery,
    int? totalCount,
    FetchRestaurantProductDetailsModel? productDetails,
    bool clearProductDetails = false,
    bool? isLoadingProductDetails,
    String? productDetailsErrorMessage,
  }) {
    return RsDiscoverState(
      restaurants: restaurants ?? this.restaurants,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      searchQuery: searchQuery ?? this.searchQuery,
      totalCount: totalCount ?? this.totalCount,
      productDetails: clearProductDetails ? null : (productDetails ?? this.productDetails),
      isLoadingProductDetails: isLoadingProductDetails ?? this.isLoadingProductDetails,
      productDetailsErrorMessage: productDetailsErrorMessage ?? this.productDetailsErrorMessage,
    );
  }
}
