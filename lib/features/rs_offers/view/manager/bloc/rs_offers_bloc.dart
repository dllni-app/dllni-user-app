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
    on<FetchRsOffersProductsEvent>(_onFetchRsOffersProducts, transformer: droppableProMax());
  }

  EventTransformer<T> droppableProMax<T extends EventWithReload>() {
    return (events, mapper) {
      return events.transform(ExhaustMapStreamTransformer(mapper));
    };
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
        final metaPerPage = meta?.perPage ?? perPage;
        final currentPage = meta?.currentPage ?? page;
        final lastPage = meta?.lastPage ?? currentPage;
        final shortPage = items.length < metaPerPage;
        final atLastPage = currentPage >= lastPage;
        final endReached = atLastPage || shortPage;

        var next = state.products.setSuccess(data: items, perPage: metaPerPage, total: meta!.total!);
        next = next.copyWith(isEndPage: endReached);

        emit(state.copyWith(products: next, errorMessage: null));
      },
    );
  }
}
