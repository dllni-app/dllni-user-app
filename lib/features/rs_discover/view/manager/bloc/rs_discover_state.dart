part of 'rs_discover_bloc.dart';

class RsDiscoverState {
  final PaginationStateModel<FetchDiscoverRestaurantsModelDataItem> restaurants;
  final int selectedTabIndex;
  final String searchQuery;
  final int totalCount;

  RsDiscoverState({
    this.restaurants = const PaginationStateModel(perPage: 10),
    this.selectedTabIndex = 0,
    this.searchQuery = '',
    this.totalCount = 0,
  });

  RsDiscoverState copyWith({
    PaginationStateModel<FetchDiscoverRestaurantsModelDataItem>? restaurants,
    int? selectedTabIndex,
    String? searchQuery,
    int? totalCount,
  }) {
    return RsDiscoverState(
      restaurants: restaurants ?? this.restaurants,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      searchQuery: searchQuery ?? this.searchQuery,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}
