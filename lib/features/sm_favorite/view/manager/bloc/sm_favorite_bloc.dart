import 'dart:async';

import 'package:common_package/helpers/droppable_helper.dart';
import 'package:common_package/helpers/pagination_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../sm_discover/data/models/browse_products_model.dart';
import '../../../../sm_discover/data/models/browse_stores_model.dart';
import '../../../domain/usecases/get_favorite_supermarket_products_use_case.dart';
import '../../../domain/usecases/get_favorite_supermarket_stores_use_case.dart';

part 'sm_favorite_event.dart';
part 'sm_favorite_state.dart';

@injectable
class SmFavoriteBloc extends Bloc<SmFavoriteEvent, SmFavoriteState> {
  final GetFavoriteSupermarketStoresUseCase getFavoriteSupermarketStoresUseCase;
  final GetFavoriteSupermarketProductsUseCase
  getFavoriteSupermarketProductsUseCase;

  SmFavoriteBloc(
    this.getFavoriteSupermarketStoresUseCase,
    this.getFavoriteSupermarketProductsUseCase,
  ) : super(SmFavoriteState()) {
    on<FetchFavoriteSupermarketStoresEvent>(
      _fetchFavoriteSupermarketStores,
      transformer: paginationEventTransformer(),
    );
    on<FetchFavoriteSupermarketProductsEvent>(
      _fetchFavoriteSupermarketProducts,
      transformer: paginationEventTransformer(),
    );
  }

  FutureOr<void> _fetchFavoriteSupermarketStores(
    FetchFavoriteSupermarketStoresEvent event,
    Emitter<SmFavoriteState> emit,
  ) async {
    if (!state.favoriteStores!.isEndPage || event.isReload) {
      emit(
        state.copyWith(
          favoriteStores: state.favoriteStores!.setLoading(
            isReload: event.isReload,
          ),
        ),
      );
      final res = await getFavoriteSupermarketStoresUseCase(event.params);
      res.fold(
        (l) {
          emit(
            state.copyWith(
              favoriteStores: state.favoriteStores!.setFaild(
                errorMessage: l.message,
              ),
              errorMessage: l.message,
            ),
          );
        },
        (r) {
          emit(
            state.copyWith(
              favoriteStores: state.favoriteStores!.setSuccess(
                total: r.meta?.total ?? 0,
                data: r.data ?? <BrowseStoresModelDataItem>[],
                perPage: r.meta?.perPage ?? 20,
              ),
            ),
          );
        },
      );
    }
  }

  FutureOr<void> _fetchFavoriteSupermarketProducts(
    FetchFavoriteSupermarketProductsEvent event,
    Emitter<SmFavoriteState> emit,
  ) async {
    if (!state.favoriteProducts!.isEndPage || event.isReload) {
      emit(
        state.copyWith(
          favoriteProducts: state.favoriteProducts!.setLoading(
            isReload: event.isReload,
          ),
        ),
      );
      final res = await getFavoriteSupermarketProductsUseCase(event.params);
      res.fold(
        (l) {
          emit(
            state.copyWith(
              favoriteProducts: state.favoriteProducts!.setFaild(
                errorMessage: l.message,
              ),
              errorMessage: l.message,
            ),
          );
        },
        (r) {
          emit(
            state.copyWith(
              favoriteProducts: state.favoriteProducts!.setSuccess(
                total: r.meta?.total ?? 0,
                data: r.data ?? <BrowseProductsModelDataItem>[],
                perPage: r.meta?.perPage ?? 20,
              ),
            ),
          );
        },
      );
    }
  }
}
