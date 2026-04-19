import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'dart:async';
import 'package:common_package/helpers/pagination_helper.dart';
import 'package:common_package/helpers/droppable_helper.dart';
import '../../../domain/usecases/browse_stores_use_case.dart';
import '../../../data/models/browse_stores_model.dart';
import '../../../domain/usecases/browse_products_use_case.dart';
import '../../../data/models/browse_products_model.dart';
import '../../../domain/usecases/change_store_favorite_use_case.dart';
import '../../../data/models/change_store_favorite_model.dart';
import '../../../domain/usecases/change_product_favorite_use_case.dart';
import '../../../data/models/change_product_favorite_model.dart';

part 'sm_discover_event.dart';
part 'sm_discover_state.dart';

@injectable
class SmDiscoverBloc extends Bloc<SmDiscoverEvent, SmDiscoverState> {
  final ChangeProductFavoriteUseCase changeProductFavoriteUseCase;
  final ChangeStoreFavoriteUseCase changeStoreFavoriteUseCase;
  final BrowseProductsUseCase browseProductsUseCase;
  final BrowseStoresUseCase browseStoresUseCase;
  SmDiscoverBloc(this.browseStoresUseCase, this.browseProductsUseCase,
    this.changeStoreFavoriteUseCase,
    this.changeProductFavoriteUseCase,)
    : super(SmDiscoverState()) {
    on<BrowseStoresEvent>(_browseStores, transformer: paginationEventTransformer());

    on<BrowseProductsEvent>(_browseProducts, transformer: paginationEventTransformer());
  
    on<ChangeStoreFavoriteEvent>(_changeStoreFavorite);
    on<ChangeProductFavoriteEvent>(_changeProductFavorite);}

  FutureOr<void> _browseStores(
    BrowseStoresEvent event,
    Emitter<SmDiscoverState> emit,
  ) async {
    if (!state.browseStores!.isEndPage || event.isReload) {
      emit(
        state.copyWith(
          browseStores: state.browseStores!.setLoading(
            isReload: event.isReload,
          ),
        ),
      );
      final res = await browseStoresUseCase(event.params);
      res.fold(
        (l) {
          emit(
            state.copyWith(
              browseStores: state.browseStores!.setFaild(
                errorMessage: l.message,
              ),
              errorMessage: l.message,
            ),
          );
        },
        (r) {
          emit(
            state.copyWith(
              browseStores: state.browseStores!.setSuccess(
                total: r.meta?.total ?? 0,
                data: r.data!,
              ),
            ),
          );
        },
      );
    }
  }

  FutureOr<void> _browseProducts(
    BrowseProductsEvent event,
    Emitter<SmDiscoverState> emit,
  ) async {
    if (!state.browseProducts!.isEndPage || event.isReload) {
      emit(
        state.copyWith(
          browseProducts: state.browseProducts!.setLoading(
            isReload: event.isReload,
          ),
        ),
      );
      final res = await browseProductsUseCase(event.params);
      res.fold(
        (l) {
          emit(
            state.copyWith(
              browseProducts: state.browseProducts!.setFaild(
                errorMessage: l.message,
              ),
              errorMessage: l.message,
            ),
          );
        },
        (r) {
          emit(
            state.copyWith(
              browseProducts: state.browseProducts!.setSuccess(
                total: r.meta?.total ?? 0,
                data: r.data!,
              ),
            ),
          );
        },
      );
    }
  }


  FutureOr<void> _changeStoreFavorite(ChangeStoreFavoriteEvent event, Emitter<SmDiscoverState> emit) async {
    emit(state.copyWith(changeStoreFavoriteStatus: BlocStatus.loading));
    final res = await changeStoreFavoriteUseCase(event.params);
    res.fold((l) {
      emit(state.copyWith(
        changeStoreFavoriteStatus: BlocStatus.failed,
        errorMessage: l.message,
      ));
    }, (r) {
      emit(state.copyWith(
        changeStoreFavoriteStatus: BlocStatus.success,
        changeStoreFavorite: r,
      ));
    });
  }

  FutureOr<void> _changeProductFavorite(ChangeProductFavoriteEvent event, Emitter<SmDiscoverState> emit) async {
    emit(state.copyWith(changeProductFavoriteStatus: BlocStatus.loading));
    final res = await changeProductFavoriteUseCase(event.params);
    res.fold((l) {
      emit(state.copyWith(
        changeProductFavoriteStatus: BlocStatus.failed,
        errorMessage: l.message,
      ));
    }, (r) {
      emit(state.copyWith(
        changeProductFavoriteStatus: BlocStatus.success,
        changeProductFavorite: r,
      ));
    });
  }}
