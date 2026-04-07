import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:common_package/helpers/droppable_helper.dart';
import 'package:common_package/helpers/pagination_helper.dart';

import '../../../data/models/fetch_discover_restaurants_model.dart';
import '../../../data/models/fetch_restaurant_product_details_model.dart';
import '../../../domain/usecases/fetch_restaurant_product_details_use_case.dart';
import '../../../domain/discover_tab_query.dart';
import '../../../domain/params/fetch_discover_restaurants_params.dart';
import '../../../domain/usecases/fetch_discover_restaurants_use_case.dart';

part 'rs_discover_event.dart';
part 'rs_discover_state.dart';

@injectable
class RsDiscoverBloc extends Bloc<RsDiscoverEvent, RsDiscoverState> {
  final FetchDiscoverRestaurantsUseCase fetchDiscoverRestaurantsUseCase;
  final FetchRestaurantProductDetailsUseCase fetchRestaurantProductDetailsUseCase;

  RsDiscoverBloc(this.fetchDiscoverRestaurantsUseCase, this.fetchRestaurantProductDetailsUseCase) : super(RsDiscoverState()) {
    on<FetchDiscoverRestaurantsEvent>(_onFetch, transformer: droppableProMax());
    on<DiscoverTabChangedEvent>(_onTabChanged);
    on<DiscoverSearchQueryChangedEvent>(_onSearchQueryChanged);
    on<FetchRestaurantProductDetailsEvent>(_onFetchProductDetails);
  }

  Timer? _searchDebounce;

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }

  EventTransformer<T> droppableProMax<T extends EventWithReload>() {
    return (events, mapper) {
      return events.transform(ExhaustMapStreamTransformer(mapper));
    };
  }

  void _onTabChanged(DiscoverTabChangedEvent event, Emitter<RsDiscoverState> emit) {
    _searchDebounce?.cancel();
    emit(state.copyWith(selectedTabIndex: event.tabIndex));
    add(FetchDiscoverRestaurantsEvent(isReload: true));
  }

  void _onSearchQueryChanged(DiscoverSearchQueryChangedEvent event, Emitter<RsDiscoverState> emit) {
    emit(state.copyWith(searchQuery: event.query));
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (isClosed) return;
      add(FetchDiscoverRestaurantsEvent(isReload: true));
    });
  }

  Future<void> _onFetch(FetchDiscoverRestaurantsEvent event, Emitter<RsDiscoverState> emit) async {
    final tabQuery = DiscoverTabQuery.fromTabIndex(state.selectedTabIndex);
    final perPage = state.restaurants.perPage;
    final isLoadMore = event.loadMore && !event.isReload;

    if (isLoadMore) {
      if (state.restaurants.isEndPage) return;
      emit(state.copyWith(restaurants: state.restaurants.setLoading(isReload: false)));
    } else {
      emit(state.copyWith(restaurants: state.restaurants.setLoading(isReload: event.isReload || state.restaurants.list.isEmpty)));
    }

    final page = isLoadMore ? state.restaurants.pageNumber : 1;

    final bool nearestSort = tabQuery.sort == 'nearest';
    final params = FetchDiscoverRestaurantsParams(
      page: page,
      perPage: perPage,
      search: state.searchQuery,
      sort: tabQuery.sort,
      filterOpenNow: tabQuery.filterOpenNow,
      filterHasOffers: tabQuery.filterHasOffers,
      latitude: nearestSort ? 31.97 : null,
      longitude: nearestSort ? 35.935 : null,
    );

    final res = await fetchDiscoverRestaurantsUseCase(params);
    res.fold(
      (l) {
        emit(state.copyWith(
          restaurants: state.restaurants.setFaild(errorMessage: l.message),
        ));
      },
      (r) {
        final items = r.data ?? [];
        final meta = r.meta;
        final metaPerPage = meta?.perPage ?? perPage;
        final currentPage = meta?.currentPage ?? page;
        final lastPage = meta?.lastPage ?? currentPage;
        final shortPage = items.length < metaPerPage;
        final atLastPage = currentPage >= lastPage;
        final endReached = atLastPage || shortPage;

        var next = state.restaurants.setSuccess(data: items, perPage: metaPerPage);
        next = next.copyWith(isEndPage: endReached);

        emit(state.copyWith(
          restaurants: next,
          totalCount: meta?.total ?? next.list.length,
        ));
      },
    );
  }

  Future<void> _onFetchProductDetails(FetchRestaurantProductDetailsEvent event, Emitter<RsDiscoverState> emit) async {
    if (event.productId <= 0) return;

    emit(state.copyWith(
      isLoadingProductDetails: true,
      productDetailsErrorMessage: '',
      clearProductDetails: true,
    ));

    final response = await fetchRestaurantProductDetailsUseCase(
      FetchRestaurantProductDetailsParams(productId: event.productId),
    );

    response.fold(
      (l) {
        emit(state.copyWith(
          isLoadingProductDetails: false,
          productDetailsErrorMessage: l.message,
        ));
      },
      (r) {
        emit(state.copyWith(
          productDetails: r,
          isLoadingProductDetails: false,
          productDetailsErrorMessage: '',
        ));
      },
    );
  }
}
