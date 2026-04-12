import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'dart:async';
import 'package:common_package/helpers/pagination_helper.dart';
import '../../../domain/usecases/get_featured_offers_use_case.dart';
import '../../../data/models/get_featured_offers_model.dart';
import '../../../domain/usecases/get_nearby_stores_use_case.dart';
import '../../../data/models/get_nearby_stores_model.dart';
import '../../../domain/usecases/change_store_favorite_use_case.dart';
import '../../../data/models/change_store_favorite_model.dart';

part 'sm_home_event.dart';
part 'sm_home_state.dart';

@injectable
class SmHomeBloc extends Bloc<SmHomeEvent, SmHomeState> {
  final ChangeStoreFavoriteUseCase changeStoreFavoriteUseCase;
  final GetNearbyStoresUseCase getNearbyStoresUseCase;
  final GetFeaturedOffersUseCase getFeaturedOffersUseCase;
  SmHomeBloc(
    this.getFeaturedOffersUseCase,
    this.getNearbyStoresUseCase,
    this.changeStoreFavoriteUseCase,) : super(SmHomeState()) {
    
  
    on<GetFeaturedOffersEvent>(_getFeaturedOffers);
    on<GetNearbyStoresEvent>(_getNearbyStores);
    on<ChangeStoreFavoriteEvent>(_changeStoreFavorite);}


  FutureOr<void> _getFeaturedOffers(GetFeaturedOffersEvent event, Emitter<SmHomeState> emit) async {
    emit(state.copyWith(featuredOffersStatus: BlocStatus.loading));
    final res = await getFeaturedOffersUseCase(event.params);
    res.fold((l) {
      emit(state.copyWith(
        featuredOffersStatus: BlocStatus.failed,
        errorMessage: l.message,
      ));
    }, (r) {
      emit(state.copyWith(
        featuredOffersStatus: BlocStatus.success,
        featuredOffers: r,
      ));
    });
  }

  FutureOr<void> _getNearbyStores(GetNearbyStoresEvent event, Emitter<SmHomeState> emit) async {
    emit(state.copyWith(nearbyStoresStatus: BlocStatus.loading));
    final res = await getNearbyStoresUseCase(event.params);
    res.fold((l) {
      emit(state.copyWith(
        nearbyStoresStatus: BlocStatus.failed,
        errorMessage: l.message,
      ));
    }, (r) {
      emit(state.copyWith(
        nearbyStoresStatus: BlocStatus.success,
        nearbyStores: r,
      ));
    });
  }

  FutureOr<void> _changeStoreFavorite(ChangeStoreFavoriteEvent event, Emitter<SmHomeState> emit) async {
    emit(state.copyWith(changeStoreFavoriteStatus: BlocStatus.loading));
    log(state.toString());
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
  }}
