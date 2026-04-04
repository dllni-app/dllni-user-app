import 'dart:async';

import 'package:common_package/helpers/droppable_helper.dart';
import 'package:common_package/helpers/pagination_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../data/models/fetch_rs_favourites_model.dart';
import '../../../domain/usecases/fetch_rs_favourites_use_case.dart';

part 'rs_favourite_event.dart';
part 'rs_favourite_state.dart';

@injectable
class RsFavouriteBloc extends Bloc<RsFavouriteEvent, RsFavouriteState> {
  final FetchRsFavouritesUseCase fetchRsFavouritesUseCase;

  RsFavouriteBloc(this.fetchRsFavouritesUseCase) : super(RsFavouriteState()) {
    on<FetchRsFavouritesEvent>(
      _fetchRsFavourites,
      transformer: droppableProMax(),
    );
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
      FetchRsFavouritesParams(page: page),
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
}
