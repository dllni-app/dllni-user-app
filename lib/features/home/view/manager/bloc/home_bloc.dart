import 'dart:async';

import 'package:common_package/common_package.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../data/models/fetch_user_offers_model.dart';
import '../../../domain/usecases/fetch_user_offers_use_case.dart';

part 'home_event.dart';
part 'home_state.dart';

@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FetchUserOffersUseCase fetchUserOffersUseCase;

  HomeBloc({required this.fetchUserOffersUseCase}) : super(HomeState()) {
    on<FetchUserOffersEvent>(_onFetchUserOffers, transformer: paginationEventTransformer());
  }

  FutureOr<void> _onFetchUserOffers(FetchUserOffersEvent event, Emitter<HomeState> emit) async {
    final pagination = state.userOffers;
    final isLoadMore = event.loadMore && !event.isReload;
    if (isLoadMore && pagination.isEndPage) return;

    emit(state.copyWith(userOffers: pagination.setLoading(isReload: event.isReload)));

    final page = isLoadMore ? pagination.pageNumber : 1;
    final perPage = pagination.perPage;
    final res = await fetchUserOffersUseCase(
      FetchUserOffersParams(page: page, perPage: perPage),
    );
    res.fold(
      (l) {
        emit(
          state.copyWith(
            userOffers: pagination.setFaild(errorMessage: l.message),
            errorMessage: l.message,
          ),
        );
      },
      (r) {
        final items = r.data;
        emit(
          state.copyWith(
            userOffers: pagination.setSuccess(
              data: items,
              total: r.meta?.total ?? pagination.total,
              perPage: r.meta?.perPage ?? perPage,
            ),
          ),
        );
      },
    );
  }
}
