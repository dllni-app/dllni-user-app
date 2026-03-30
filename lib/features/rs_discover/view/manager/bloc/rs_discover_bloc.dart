import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/material.dart';

import '../../screens/rs_restaurant_detail_screen.dart';


part 'rs_discover_event.dart';
part 'rs_discover_state.dart';

@injectable
class RsDiscoverBloc extends Bloc<RsDiscoverEvent, RsDiscoverState> {
  RsDiscoverBloc() : super(RsDiscoverState.initial()) {
    on<RsDiscoverFilterChanged>(_onFilterChanged);
    on<RsDiscoverSortChanged>(_onSortChanged);
  }

  void _onFilterChanged(
    RsDiscoverFilterChanged event,
    Emitter<RsDiscoverState> emit,
  ) {
    final updatedState = state.copyWith(
      selectedFilterIndex: event.filterIndex,
      visibleRestaurants: _buildVisibleRestaurants(
        restaurants: state.restaurants,
        selectedFilterIndex: event.filterIndex,
        selectedSort: state.selectedSort,
      ),
    );
    emit(updatedState);
  }

  void _onSortChanged(RsDiscoverSortChanged event, Emitter<RsDiscoverState> emit) {
    final updatedState = state.copyWith(
      selectedSort: event.sort,
      visibleRestaurants: _buildVisibleRestaurants(
        restaurants: state.restaurants,
        selectedFilterIndex: state.selectedFilterIndex,
        selectedSort: event.sort,
      ),
    );
    emit(updatedState);
  }

  List<RsRestaurantListItem> _buildVisibleRestaurants({
    required List<RsRestaurantListItem> restaurants,
    required int selectedFilterIndex,
    required RsDiscoverSort selectedSort,
  }) {
    final filtered = restaurants.where((restaurant) {
      switch (selectedFilterIndex) {
        case 1:
          return restaurant.isNearby;
        case 2:
          return restaurant.rating >= 4.7;
        case 3:
          return restaurant.isFastDelivery;
        case 4:
          return restaurant.hasOffer;
        case 5:
          return restaurant.isOpen;
        case 0:
        default:
          return true;
      }
    }).toList();

    filtered.sort((a, b) {
      switch (selectedSort) {
        case RsDiscoverSort.highestRated:
          return b.rating.compareTo(a.rating);
        case RsDiscoverSort.fastestDelivery:
          return _extractFirstNumberFromText(a.deliveryTimeLabel).compareTo(
            _extractFirstNumberFromText(b.deliveryTimeLabel),
          );
        case RsDiscoverSort.nearest:
          return _extractFirstNumberFromText(
            a.distanceLabel,
          ).compareTo(_extractFirstNumberFromText(b.distanceLabel));
      }
    });

    return filtered;
  }

  double _extractFirstNumberFromText(String value) {
    final match = RegExp(r'\d+(\.\d+)?').firstMatch(value);
    if (match == null) {
      return 0;
    }
    return double.tryParse(match.group(0) ?? '') ?? 0;
  }
}
