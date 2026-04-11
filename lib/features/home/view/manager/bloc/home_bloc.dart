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

  HomeBloc({required this.fetchUserOffersUseCase}) : super(HomeState(userOffersStatus: BlocStatus.init)) {
    on<FetchUserOffersEvent>(_onFetchUserOffers);
  }

  FutureOr<void> _onFetchUserOffers(FetchUserOffersEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(userOffersStatus: BlocStatus.loading));
    final res = await fetchUserOffersUseCase(event.params);
    res.fold(
      (l) {
        emit(
          state.copyWith(
            userOffersStatus: BlocStatus.failed,
            errorMessage: l.message,
          ),
        );
      },
      (r) {
        emit(
          state.copyWith(
            userOffersStatus: BlocStatus.success,
            userOffers: r,
          ),
        );
      },
    );
  }
}
