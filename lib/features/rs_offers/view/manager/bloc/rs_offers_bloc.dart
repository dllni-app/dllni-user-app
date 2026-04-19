import 'dart:async';

import 'package:common_package/helpers/droppable_helper.dart';
import 'package:common_package/helpers/pagination_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../data/models/fetch_rs_offers_products_model.dart';
import '../../../domain/usecases/fetch_rs_offers_products_use_case.dart';

part 'rs_offers_event.dart';

part 'rs_offers_state.dart';

@injectable
class RsOffersBloc extends Bloc<RsOffersEvent, RsOffersState> {
  final FetchRsOffersProductsUseCase fetchRsOffersProductsUseCase;

  RsOffersBloc(this.fetchRsOffersProductsUseCase) : super(RsOffersState()) {
    on<FetchRsOffersProductsEvent>(_onFetchRsOffersProducts, transformer: paginationEventTransformer());
  }

  FutureOr<void> _onFetchRsOffersProducts(FetchRsOffersProductsEvent event, Emitter<RsOffersState> emit) async {
    final perPage = state.products.perPage;
    final isLoadMore = event.loadMore && !event.isReload;

    if (isLoadMore) {
      if (state.products.isEndPage || state.products.status == BlocStatus.loading) {
        return;
      }
      emit(state.copyWith(products: state.products.setLoading(isReload: false)));
    } else {
      emit(state.copyWith(products: state.products.setLoading(isReload: event.isReload || state.products.list.isEmpty)));
    }

    final page = isLoadMore ? state.products.pageNumber : 1;
    final res = await fetchRsOffersProductsUseCase(FetchRsOffersProductsParams(page: page, perPage: perPage));

    res.fold(
      (l) {
        emit(
          state.copyWith(
            products: state.products.setFaild(errorMessage: l.message),
            errorMessage: l.message,
          ),
        );
      },
      (r) {
        final items = r.data ?? <FetchRsOffersProductsModelDataItem>[];
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

        emit(state.copyWith(products: next, errorMessage: null));
      },
    );
  }
}
