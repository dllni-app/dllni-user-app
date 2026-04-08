import 'dart:async';

import 'package:common_package/helpers/pagination_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../data/models/get_supermarket_product_details_model.dart';
import '../../../data/models/get_supermarket_store_details_model.dart';
import '../../../domain/usecases/get_supermarket_product_details_use_case.dart';
import '../../../domain/usecases/get_supermarket_store_details_use_case.dart';
import 'package:common_package/helpers/droppable_helper.dart';
import '../../../domain/usecases/get_compare_products_use_case.dart';
import '../../../data/models/get_compare_products_model.dart';

part 'sm_stores_event.dart';
part 'sm_stores_state.dart';

@injectable
class SmStoresBloc extends Bloc<SmStoresEvent, SmStoresState> {
  final GetCompareProductsUseCase getCompareProductsUseCase;
  final GetSupermarketStoreDetailsUseCase getSupermarketStoreDetailsUseCase;
  final GetSupermarketProductDetailsUseCase getSupermarketProductDetailsUseCase;

  SmStoresBloc(
    this.getSupermarketStoreDetailsUseCase,
    this.getSupermarketProductDetailsUseCase,
    this.getCompareProductsUseCase,) : super(SmStoresState()) {
    on<LoadSupermarketStoreDetailsEvent>(_loadSupermarketStoreDetails);
    on<LoadSupermarketProductDetailsEvent>(_loadSupermarketProductDetails);
  
    on<GetCompareProductsEvent>(_getCompareProducts, transformer: droppableProMax());}

  FutureOr<void> _loadSupermarketStoreDetails(
    LoadSupermarketStoreDetailsEvent event,
    Emitter<SmStoresState> emit,
  ) async {
    emit(
      state.copyWith(
        storeDetailsStatus: BlocStatus.loading,
        errorMessage: null,
      ),
    );
    final res = await getSupermarketStoreDetailsUseCase(
      GetSupermarketStoreDetailsParams(storeId: event.storeId),
    );
    res.fold(
      (l) {
        emit(
          state.copyWith(
            storeDetailsStatus: BlocStatus.failed,
            errorMessage: l.message,
          ),
        );
      },
      (r) {
        emit(
          state.copyWith(
            storeDetailsStatus: BlocStatus.success,
            store: r.store,
            errorMessage: null,
          ),
        );
      },
    );
  }

  FutureOr<void> _loadSupermarketProductDetails(
    LoadSupermarketProductDetailsEvent event,
    Emitter<SmStoresState> emit,
  ) async {
    emit(
      state.toProductDetailsLoading(),
    );
    final res = await getSupermarketProductDetailsUseCase(
      GetSupermarketProductDetailsParams(productId: event.productId),
    );
    res.fold(
      (l) {
        emit(
          state.copyWith(
            productDetailsStatus: BlocStatus.failed,
            errorMessage: l.message,
          ),
        );
      },
      (r) {
        emit(
          state.copyWith(
            productDetailsStatus: BlocStatus.success,
            productDetails: r.product,
            errorMessage: null,
          ),
        );
      },
    );
  }


  EventTransformer<T> droppableProMax<T extends EventWithReload>() {
    return (events, mapper) {
      return events.transform(ExhaustMapStreamTransformer(mapper));
    };
  }

  FutureOr<void> _getCompareProducts(GetCompareProductsEvent event, Emitter<SmStoresState> emit) async {
    if (!state.compareProducts!.isEndPage || event.isReload) {
      emit(state.copyWith(
        compareProducts: state.compareProducts!.setLoading(isReload: event.isReload),
      ));
      final res = await getCompareProductsUseCase(event.params);
      res.fold((l) {
        emit(state.copyWith(
          compareProducts: state.compareProducts!.setFaild(errorMessage: l.message),
          errorMessage: l.message,
        ));
      }, (r) {
        emit(state.copyWith(
          compareProducts: state.compareProducts!.setSuccess(
            total: r.meta?.total ?? 0,
            data: r.data!),
        ));
      });
    }
  }}
