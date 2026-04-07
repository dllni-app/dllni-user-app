import 'dart:async';

import 'package:common_package/helpers/droppable_helper.dart';
import 'package:common_package/helpers/pagination_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../data/models/fetch_favourite_products_model.dart';
import '../../../data/models/fetch_rs_favourites_model.dart';
import '../../../domain/usecases/fetch_favourite_products_use_case.dart';
import '../../../domain/usecases/fetch_rs_favourites_use_case.dart';
import '../../../domain/usecases/toggle_product_favourite_use_case.dart';
import '../../../domain/usecases/toggle_restaurant_favourite_use_case.dart';

part 'rs_favourite_event.dart';
part 'rs_favourite_state.dart';

@injectable
class RsFavouriteBloc extends Bloc<RsFavouriteEvent, RsFavouriteState> {
  final FetchRsFavouritesUseCase fetchRsFavouritesUseCase;
  final FetchFavouriteProductsUseCase fetchFavouriteProductsUseCase;
  final ToggleRestaurantFavouriteUseCase toggleRestaurantFavouriteUseCase;
  final ToggleProductFavouriteUseCase toggleProductFavouriteUseCase;

  RsFavouriteBloc(
    this.fetchRsFavouritesUseCase,
    this.fetchFavouriteProductsUseCase,
    this.toggleRestaurantFavouriteUseCase,
    this.toggleProductFavouriteUseCase,
  ) : super(RsFavouriteState()) {
    on<FetchRsFavouritesEvent>(
      _fetchRsFavourites,
      transformer: droppableProMax(),
    );
    on<FetchFavouriteProductsEvent>(
      _fetchFavouriteProducts,
      transformer: droppableProMax(),
    );
    on<RemoveFavouriteRestaurantEvent>(_removeFavouriteRestaurant);
    on<RemoveFavouriteProductEvent>(_removeFavouriteProduct);
  }

  EventTransformer<T> droppableProMax<T extends EventWithReload>() {
    return (events, mapper) {
      return events.transform(ExhaustMapStreamTransformer(mapper));
    };
  }

  FutureOr<void> _fetchRsFavourites(
    FetchRsFavouritesEvent event,
    Emitter<RsFavouriteState> emit,
  ) async {
    final perPage = state.rsFavourites.perPage;
    final isLoadMore = event.loadMore && !event.isReload;

    if (isLoadMore) {
      if (state.rsFavourites.isEndPage ||
          state.rsFavourites.status == BlocStatus.loading) {
        return;
      }
      emit(
        state.copyWith(
          rsFavourites: state.rsFavourites.setLoading(isReload: false),
        ),
      );
    } else {
      emit(
        state.copyWith(
          rsFavourites: state.rsFavourites.setLoading(
            isReload: event.isReload || state.rsFavourites.list.isEmpty,
          ),
        ),
      );
    }

    final page = isLoadMore ? state.rsFavourites.pageNumber : event.params.page;
    final res = await fetchRsFavouritesUseCase(
      FetchRsFavouritesParams(page: page, perPage: perPage),
    );

    res.fold(
      (l) {
        emit(
          state.copyWith(
            rsFavourites: state.rsFavourites.setFaild(errorMessage: l.message),
            errorMessage: l.message,
          ),
        );
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

        var next = state.rsFavourites.setSuccess(
          data: items,
          perPage: metaPerPage,
        );
        next = next.copyWith(isEndPage: endReached);

        emit(state.copyWith(rsFavourites: next));
      },
    );
  }

  FutureOr<void> _fetchFavouriteProducts(
    FetchFavouriteProductsEvent event,
    Emitter<RsFavouriteState> emit,
  ) async {
    final perPage = state.productFavourites.perPage;
    final isLoadMore = event.loadMore && !event.isReload;

    if (isLoadMore) {
      if (state.productFavourites.isEndPage || state.productFavourites.status == BlocStatus.loading) {
        return;
      }
      emit(
        state.copyWith(
          productFavourites: state.productFavourites.setLoading(isReload: false),
        ),
      );
    } else {
      emit(
        state.copyWith(
          productFavourites: state.productFavourites.setLoading(
            isReload: event.isReload || state.productFavourites.list.isEmpty,
          ),
        ),
      );
    }

    final page = isLoadMore ? state.productFavourites.pageNumber : event.params.page;
    final res = await fetchFavouriteProductsUseCase(
      FetchFavouriteProductsParams(page: page, perPage: perPage),
    );

    res.fold(
      (l) {
        emit(
          state.copyWith(
            productFavourites: state.productFavourites.setFaild(errorMessage: l.message),
            errorMessage: l.message,
          ),
        );
      },
      (r) {
        final items = r.data;
        final meta = r.meta;
        final metaPerPage = meta?.perPage ?? perPage;
        final currentPage = meta?.currentPage ?? page;
        final lastPage = meta?.lastPage ?? currentPage;
        final shortPage = items.length < metaPerPage;
        final atLastPage = currentPage >= lastPage;
        final endReached = atLastPage || shortPage;

        var next = state.productFavourites.setSuccess(
          data: items,
          perPage: metaPerPage,
        );
        next = next.copyWith(isEndPage: endReached);

        emit(state.copyWith(productFavourites: next));
      },
    );
  }

  void _removeFavouriteRestaurant(
    RemoveFavouriteRestaurantEvent event,
    Emitter<RsFavouriteState> emit,
  ) {
    if (event.restaurantId <= 0) return;

    final current = state.rsFavourites.list;
    final updated = current.where((item) => item.id != event.restaurantId).toList();
    if (updated.length == current.length) return;

    emit(
      state.copyWith(
        rsFavourites: state.rsFavourites.copyWith(
          list: updated,
          status: BlocStatus.success,
        ),
      ),
    );

    unawaited(
      toggleRestaurantFavouriteUseCase(
        ToggleRestaurantFavouriteParams(
          restaurantId: event.restaurantId,
          isFavorited: false,
        ),
      ),
    );
  }

  void _removeFavouriteProduct(
    RemoveFavouriteProductEvent event,
    Emitter<RsFavouriteState> emit,
  ) {
    if (event.productId <= 0) return;

    final current = state.productFavourites.list;
    final updated = current.where((item) => item.id != event.productId).toList();
    if (updated.length == current.length) return;

    emit(
      state.copyWith(
        productFavourites: state.productFavourites.copyWith(
          list: updated,
          status: BlocStatus.success,
        ),
      ),
    );

    unawaited(
      toggleProductFavouriteUseCase(
        ToggleProductFavouriteParams(
          productId: event.productId,
          isFavorited: false,
        ),
      ),
    );
  }
}
