import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:common_package/helpers/droppable_helper.dart';
import 'package:common_package/helpers/pagination_helper.dart';
import '../../../../../core/di/injection.dart';
import '../../../../profile/domain/services/user_location_service.dart';

import '../../../data/models/fetch_discover_restaurants_model.dart';
import '../../../data/models/fetch_restaurant_product_details_model.dart';
import '../../../data/models/fetch_restaurant_products_search_model.dart';
import '../../../domain/usecases/fetch_restaurant_product_details_use_case.dart';
import '../../../domain/discover_tab_query.dart';
import '../../../domain/params/fetch_discover_restaurants_params.dart';
import '../../../domain/usecases/fetch_discover_restaurants_use_case.dart';
import '../../../domain/usecases/fetch_restaurant_products_search_use_case.dart';

part 'rs_discover_event.dart';

part 'rs_discover_state.dart';

@injectable
class RsDiscoverBloc extends Bloc<RsDiscoverEvent, RsDiscoverState> {
  final FetchDiscoverRestaurantsUseCase fetchDiscoverRestaurantsUseCase;
  final FetchRestaurantProductDetailsUseCase
  fetchRestaurantProductDetailsUseCase;
  final FetchRestaurantProductsSearchUseCase
  fetchRestaurantProductsSearchUseCase;
  final UserLocationService userLocationService;

  RsDiscoverBloc(
    this.fetchDiscoverRestaurantsUseCase,
    this.fetchRestaurantProductDetailsUseCase,
    this.userLocationService, {
    FetchRestaurantProductsSearchUseCase? fetchRestaurantProductsSearchUseCase,
  }) : fetchRestaurantProductsSearchUseCase =
           fetchRestaurantProductsSearchUseCase ??
           getIt<FetchRestaurantProductsSearchUseCase>(),
       super(RsDiscoverState()) {
    on<FetchDiscoverRestaurantsEvent>(
      _onFetch,
      transformer: paginationEventTransformer(),
    );
    on<FetchDiscoverProductsEvent>(
      _onFetchProducts,
      transformer: paginationEventTransformer(),
    );
    on<DiscoverTabChangedEvent>(_onTabChanged);
    on<DiscoverSearchModeChangedEvent>(_onSearchModeChanged);
    on<DiscoverSearchQueryChangedEvent>(_onSearchQueryChanged);
    on<DiscoverProductSearchQueryChangedEvent>(_onProductSearchQueryChanged);
    on<FetchRestaurantProductDetailsEvent>(_onFetchProductDetails);
  }

  Timer? _searchDebounce;

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }

  void _onTabChanged(
    DiscoverTabChangedEvent event,
    Emitter<RsDiscoverState> emit,
  ) {
    _searchDebounce?.cancel();
    emit(state.copyWith(selectedTabIndex: event.tabIndex));
    add(FetchDiscoverRestaurantsEvent(isReload: true));
  }

  void _onSearchQueryChanged(
    DiscoverSearchQueryChangedEvent event,
    Emitter<RsDiscoverState> emit,
  ) {
    emit(
      state.copyWith(
        activeSearchMode: RsDiscoverSearchMode.restaurant,
        searchQuery: event.query,
      ),
    );
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (isClosed) return;
      add(FetchDiscoverRestaurantsEvent(isReload: true));
    });
  }

  void _onProductSearchQueryChanged(
    DiscoverProductSearchQueryChangedEvent event,
    Emitter<RsDiscoverState> emit,
  ) {
    emit(
      state.copyWith(
        activeSearchMode: event.resultingMode ?? RsDiscoverSearchMode.meal,
        productSearchQuery: event.query,
      ),
    );
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (isClosed) return;
      add(FetchDiscoverProductsEvent(isReload: true));
    });
  }

  void _onSearchModeChanged(
    DiscoverSearchModeChangedEvent event,
    Emitter<RsDiscoverState> emit,
  ) {
    if (state.activeSearchMode == event.mode) return;
    _searchDebounce?.cancel();
    emit(state.copyWith(activeSearchMode: event.mode));
  }

  Future<void> _onFetch(
    FetchDiscoverRestaurantsEvent event,
    Emitter<RsDiscoverState> emit,
  ) async {
    final tabQuery = DiscoverTabQuery.fromTabIndex(state.selectedTabIndex);
    final perPage = state.restaurants.perPage;
    final isLoadMore = event.loadMore && !event.isReload;

    if (isLoadMore) {
      if (state.restaurants.isEndPage ||
          state.restaurants.status == BlocStatus.loading)
        return;
      emit(
        state.copyWith(
          restaurants: state.restaurants.setLoading(isReload: false),
        ),
      );
    } else {
      emit(
        state.copyWith(
          restaurants: state.restaurants.setLoading(
            isReload: event.isReload || state.restaurants.list.isEmpty,
          ),
        ),
      );
    }

    final page = isLoadMore ? state.restaurants.pageNumber : 1;

    final bool nearestSort = tabQuery.sort == 'nearest';
    double? latitude;
    double? longitude;
    if (nearestSort) {
      if (isLoadMore) {
        latitude = state.nearestLatitude;
        longitude = state.nearestLongitude;
      }
      if (latitude == null || longitude == null) {
        final loc = await userLocationService.getCurrentPosition();
        latitude = loc.latitude;
        longitude = loc.longitude;
      }
      if (latitude == null || longitude == null) {
        emit(
          state.copyWith(
            restaurants: state.restaurants.setFaild(
              errorMessage:
                  'لم نتمكن من الحصول على موقعك. فعّل صلاحية الموقع وخدمة تحديد الموقع.',
            ),
            resetNearestCoords: true,
          ),
        );
        return;
      }
    }

    final params = FetchDiscoverRestaurantsParams(
      page: page,
      perPage: perPage,
      search: state.searchQuery,
      sort: tabQuery.sort,
      filterOpenNow: tabQuery.filterOpenNow,
      filterHasOffers: tabQuery.filterHasOffers,
      latitude: nearestSort ? latitude : null,
      longitude: nearestSort ? longitude : null,
    );

    final res = await fetchDiscoverRestaurantsUseCase(params);
    res.fold(
      (l) {
        emit(
          state.copyWith(
            restaurants: state.restaurants.setFaild(errorMessage: l.message),
          ),
        );
      },
      (r) {
        final items = r.data ?? [];
        final meta = r.meta;
        final next = setPaginatedSuccessFromMeta(
          current: state.restaurants,
          data: items,
          total: meta?.total ?? state.restaurants.total,
          requestedPage: page,
          fallbackPerPage: perPage,
          metaCurrentPage: meta?.currentPage,
          metaLastPage: meta?.lastPage,
          metaPerPage: meta?.perPage,
        );

        emit(
          state.copyWith(
            restaurants: next,
            totalCount: meta?.total ?? next.list.length,
            resetNearestCoords: !nearestSort,
            nearestLatitude: nearestSort ? latitude : null,
            nearestLongitude: nearestSort ? longitude : null,
          ),
        );
      },
    );
  }

  Future<void> _onFetchProducts(
    FetchDiscoverProductsEvent event,
    Emitter<RsDiscoverState> emit,
  ) async {
    final perPage = state.products.perPage;
    final isLoadMore = event.loadMore && !event.isReload;

    if (isLoadMore) {
      if (state.products.isEndPage ||
          state.products.status == BlocStatus.loading)
        return;
      emit(
        state.copyWith(products: state.products.setLoading(isReload: false)),
      );
    } else {
      emit(
        state.copyWith(
          products: state.products.setLoading(
            isReload: event.isReload || state.products.list.isEmpty,
          ),
        ),
      );
    }

    final page = isLoadMore ? state.products.pageNumber : 1;
    final params = FetchRestaurantProductsSearchParams(
      page: page,
      perPage: perPage,
      text: state.productSearchQuery,
    );

    final res = await fetchRestaurantProductsSearchUseCase(params);
    res.fold(
      (l) {
        emit(
          state.copyWith(
            products: state.products.setFaild(errorMessage: l.message),
          ),
        );
      },
      (r) {
        final items = r.data ?? <FetchRestaurantProductsSearchModelDataItem>[];
        final meta = r.meta;
        final next = setPaginatedSuccessFromMeta(
          current: state.products,
          data: items,
          total: meta?.total ?? state.products.total,
          requestedPage: page,
          fallbackPerPage: perPage,
          metaCurrentPage: meta?.currentPage,
          metaLastPage: meta?.lastPage,
          metaPerPage: meta?.perPage,
        );

        emit(state.copyWith(products: next));
      },
    );
  }

  Future<void> _onFetchProductDetails(
    FetchRestaurantProductDetailsEvent event,
    Emitter<RsDiscoverState> emit,
  ) async {
    if (event.productId <= 0) return;

    emit(
      state.copyWith(
        isLoadingProductDetails: true,
        productDetailsErrorMessage: '',
        clearProductDetails: true,
      ),
    );

    final response = await fetchRestaurantProductDetailsUseCase(
      FetchRestaurantProductDetailsParams(productId: event.productId),
    );

    response.fold(
      (l) {
        emit(
          state.copyWith(
            isLoadingProductDetails: false,
            productDetailsErrorMessage: l.message,
          ),
        );
      },
      (r) {
        emit(
          state.copyWith(
            productDetails: r,
            isLoadingProductDetails: false,
            productDetailsErrorMessage: '',
          ),
        );
      },
    );
  }
}
