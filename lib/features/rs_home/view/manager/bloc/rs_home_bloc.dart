import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'dart:async';
import 'package:common_package/helpers/pagination_helper.dart';
import 'package:common_package/helpers/droppable_helper.dart';
import '../../../../../core/cart/cart_products_count_cubit.dart';
import '../../../../../core/di/injection.dart';
import '../../../domain/usecases/fetch_stores_use_case.dart';
import '../../../data/models/fetch_stores_model.dart';
import '../../../domain/usecases/fetch_near_by_stores_use_case.dart';
import '../../../data/models/fetch_near_by_stores_model.dart';
import '../../../domain/usecases/fetch_featured_offers_use_case.dart';
import '../../../data/models/fetch_featured_offers_model.dart';
import '../../../domain/usecases/fetch_restaurant_home_categories_use_case.dart';
import '../../../data/models/fetch_restaurant_home_categories_model.dart';
import '../../../domain/usecases/fetch_restaurant_home_exclusive_offers_use_case.dart';
import '../../../data/models/fetch_restaurant_home_exclusive_offers_model.dart';
import '../../../domain/usecases/fetch_restaurant_home_suggested_products_use_case.dart';
import '../../../data/models/fetch_restaurant_home_suggested_products_model.dart';
import '../../../domain/usecases/fetch_restaurant_home_nearest_restaurants_use_case.dart';
import '../../../data/models/fetch_restaurant_home_nearest_restaurants_model.dart';
import '../../../domain/usecases/fetch_restaurant_home_latest_ordered_products_use_case.dart';
import '../../../data/models/fetch_restaurant_home_latest_ordered_products_model.dart';
import '../../../domain/usecases/fetch_restaurant_home_category_products_use_case.dart';
import '../../../data/models/fetch_restaurant_home_category_products_model.dart';
import '../../../domain/usecases/reorder_latest_ordered_product_use_case.dart';

part 'rs_home_event.dart';

part 'rs_home_state.dart';

@injectable
class RsHomeBloc extends Bloc<RsHomeEvent, RsHomeState> {
  final FetchRestaurantHomeCategoriesUseCase fetchRestaurantHomeCategoriesUseCase;
  final FetchRestaurantHomeExclusiveOffersUseCase fetchRestaurantHomeExclusiveOffersUseCase;
  final FetchRestaurantHomeSuggestedProductsUseCase fetchRestaurantHomeSuggestedProductsUseCase;
  final FetchRestaurantHomeNearestRestaurantsUseCase fetchRestaurantHomeNearestRestaurantsUseCase;
  final FetchRestaurantHomeLatestOrderedProductsUseCase fetchRestaurantHomeLatestOrderedProductsUseCase;
  final ReorderLatestOrderedProductUseCase reorderLatestOrderedProductUseCase;
  final FetchRestaurantHomeCategoryProductsUseCase fetchRestaurantHomeCategoryProductsUseCase;
  final FetchFeaturedOffersUseCase fetchFeaturedOffersUseCase;
  final FetchNearByStoresUseCase fetchNearByStoresUseCase;
  final FetchStoresUseCase fetchStoresUseCase;

  RsHomeBloc(
    this.fetchStoresUseCase,
    this.fetchNearByStoresUseCase,
    this.fetchFeaturedOffersUseCase,
    this.fetchRestaurantHomeCategoriesUseCase,
    this.fetchRestaurantHomeExclusiveOffersUseCase,
    this.fetchRestaurantHomeSuggestedProductsUseCase,
    this.fetchRestaurantHomeNearestRestaurantsUseCase,
    this.fetchRestaurantHomeLatestOrderedProductsUseCase,
    this.reorderLatestOrderedProductUseCase,
    this.fetchRestaurantHomeCategoryProductsUseCase,
  ) : super(RsHomeState()) {
    on<FetchStoresEvent>(_fetchStores, transformer: droppableProMax());
    on<FetchNearByStoresEvent>(_fetchNearByStores);
    on<FetchFeaturedOffersEvent>(_fetchFeaturedOffers);
    on<FetchRestaurantHomeCategoriesEvent>(_fetchRestaurantHomeCategories);
    on<FetchRestaurantHomeExclusiveOffersEvent>(_fetchRestaurantHomeExclusiveOffers);
    on<FetchRestaurantHomeSuggestedProductsEvent>(_fetchRestaurantHomeSuggestedProducts);
    on<FetchRestaurantHomeNearestRestaurantsEvent>(_fetchRestaurantHomeNearestRestaurants);
    on<FetchRestaurantHomeLatestOrderedProductsEvent>(_fetchRestaurantHomeLatestOrderedProducts);
    on<ReorderLatestOrderedProductEvent>(_reorderLatestOrderedProduct);
    on<FetchRestaurantHomeCategoryProductsEvent>(_fetchRestaurantHomeCategoryProducts);
  }

  EventTransformer<T> droppableProMax<T extends EventWithReload>() {
    return (events, mapper) {
      return events.transform(ExhaustMapStreamTransformer(mapper));
    };
  }

  FutureOr<void> _fetchStores(FetchStoresEvent event, Emitter<RsHomeState> emit) async {
    if (!state.stores!.isEndPage || event.isReload) {
      emit(state.copyWith(stores: state.stores!.setLoading(isReload: event.isReload)));
      final res = await fetchStoresUseCase(event.params);
      res.fold(
        (l) {
          emit(
            state.copyWith(
              stores: state.stores!.setFaild(errorMessage: l.message),
              errorMessage: l.message,
            ),
          );
        },
        (r) {
          emit(state.copyWith(stores: state.stores!.setSuccess(data: r.data!)));
        },
      );
    }
  }

  FutureOr<void> _fetchNearByStores(FetchNearByStoresEvent event, Emitter<RsHomeState> emit) async {
    emit(state.copyWith(nearByStoresStatus: BlocStatus.loading));
    final res = await fetchNearByStoresUseCase(event.params);
    res.fold(
      (l) {
        emit(state.copyWith(nearByStoresStatus: BlocStatus.failed, errorMessage: l.message));
      },
      (r) {
        emit(state.copyWith(nearByStoresStatus: BlocStatus.success, nearByStores: r));
      },
    );
  }

  FutureOr<void> _fetchFeaturedOffers(FetchFeaturedOffersEvent event, Emitter<RsHomeState> emit) async {
    emit(state.copyWith(featuredOffersStatus: BlocStatus.loading));
    final res = await fetchFeaturedOffersUseCase(event.params);
    res.fold(
      (l) {
        emit(state.copyWith(featuredOffersStatus: BlocStatus.failed, errorMessage: l.message));
      },
      (r) {
        emit(state.copyWith(featuredOffersStatus: BlocStatus.success, featuredOffers: r));
      },
    );
  }

  FutureOr<void> _fetchRestaurantHomeCategories(FetchRestaurantHomeCategoriesEvent event, Emitter<RsHomeState> emit) async {
    emit(state.copyWith(restaurantCategoriesStatus: BlocStatus.loading));
    final res = await fetchRestaurantHomeCategoriesUseCase(event.params);
    res.fold(
      (l) {
        emit(state.copyWith(restaurantCategoriesStatus: BlocStatus.failed, errorMessage: l.message));
      },
      (r) {
        emit(state.copyWith(restaurantCategoriesStatus: BlocStatus.success, restaurantCategories: r));
      },
    );
  }

  FutureOr<void> _fetchRestaurantHomeExclusiveOffers(FetchRestaurantHomeExclusiveOffersEvent event, Emitter<RsHomeState> emit) async {
    emit(state.copyWith(restaurantExclusiveOffersStatus: BlocStatus.loading));
    final res = await fetchRestaurantHomeExclusiveOffersUseCase(event.params);
    res.fold(
      (l) {
        emit(state.copyWith(restaurantExclusiveOffersStatus: BlocStatus.failed, errorMessage: l.message));
      },
      (r) {
        emit(state.copyWith(restaurantExclusiveOffersStatus: BlocStatus.success, restaurantExclusiveOffers: r));
      },
    );
  }

  FutureOr<void> _fetchRestaurantHomeSuggestedProducts(FetchRestaurantHomeSuggestedProductsEvent event, Emitter<RsHomeState> emit) async {
    emit(state.copyWith(restaurantSuggestedProductsStatus: BlocStatus.loading));
    final res = await fetchRestaurantHomeSuggestedProductsUseCase(event.params);
    res.fold(
      (l) {
        emit(state.copyWith(restaurantSuggestedProductsStatus: BlocStatus.failed, errorMessage: l.message));
      },
      (r) {
        emit(state.copyWith(restaurantSuggestedProductsStatus: BlocStatus.success, restaurantSuggestedProducts: r));
      },
    );
  }

  FutureOr<void> _fetchRestaurantHomeNearestRestaurants(FetchRestaurantHomeNearestRestaurantsEvent event, Emitter<RsHomeState> emit) async {
    emit(state.copyWith(restaurantNearestRestaurantsStatus: BlocStatus.loading));
    final res = await fetchRestaurantHomeNearestRestaurantsUseCase(event.params);
    res.fold(
      (l) {
        emit(state.copyWith(restaurantNearestRestaurantsStatus: BlocStatus.failed, errorMessage: l.message));
      },
      (r) {
        emit(state.copyWith(restaurantNearestRestaurantsStatus: BlocStatus.success, restaurantNearestRestaurants: r));
      },
    );
  }

  FutureOr<void> _fetchRestaurantHomeLatestOrderedProducts(FetchRestaurantHomeLatestOrderedProductsEvent event, Emitter<RsHomeState> emit) async {
    emit(state.copyWith(restaurantLatestOrderedProductsStatus: BlocStatus.loading));
    final res = await fetchRestaurantHomeLatestOrderedProductsUseCase(event.params);
    res.fold(
      (l) {
        emit(state.copyWith(restaurantLatestOrderedProductsStatus: BlocStatus.failed, errorMessage: l.message));
      },
      (r) {
        emit(state.copyWith(restaurantLatestOrderedProductsStatus: BlocStatus.success, restaurantLatestOrderedProducts: r));
      },
    );
  }

  FutureOr<void> _fetchRestaurantHomeCategoryProducts(FetchRestaurantHomeCategoryProductsEvent event, Emitter<RsHomeState> emit) async {
    emit(state.copyWith(restaurantCategoryProductsStatus: BlocStatus.loading));
    final res = await fetchRestaurantHomeCategoryProductsUseCase(event.params);
    res.fold(
      (l) {
        emit(state.copyWith(restaurantCategoryProductsStatus: BlocStatus.failed, errorMessage: l.message));
      },
      (r) {
        emit(state.copyWith(restaurantCategoryProductsStatus: BlocStatus.success, restaurantCategoryProducts: r));
      },
    );
  }

  FutureOr<void> _reorderLatestOrderedProduct(ReorderLatestOrderedProductEvent event, Emitter<RsHomeState> emit) async {
    if (state.restaurantReorderStatus == BlocStatus.loading) return;
    emit(state.copyWith(restaurantReorderStatus: BlocStatus.loading));
    final res = await reorderLatestOrderedProductUseCase(const ReorderLatestOrderedProductParams());
    res.fold(
      (l) {
        emit(state.copyWith(restaurantReorderStatus: BlocStatus.failed, errorMessage: l.message));
      },
      (_) {
        getIt<CartProductsCountCubit>().refreshAfterAdd();
        emit(state.copyWith(restaurantReorderStatus: BlocStatus.success));
      },
    );
  }
}
