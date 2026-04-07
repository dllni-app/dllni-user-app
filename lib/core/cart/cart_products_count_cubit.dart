import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/rs_discover/domain/usecases/fetch_restaurant_cart_products_count_use_case.dart';

class CartProductsCountCubit extends Cubit<int> {
  CartProductsCountCubit({required this.fetchRestaurantCartProductsCountUseCase}) : super(0);

  final FetchRestaurantCartProductsCountUseCase fetchRestaurantCartProductsCountUseCase;

  Future<void> fetchCount() async {
    final res = await fetchRestaurantCartProductsCountUseCase(FetchRestaurantCartProductsCountParams());
    if (isClosed) return;
    res.fold((_) => emit(0), (r) => emit(r.productsCount));
  }

  Future<void> refreshAfterAdd() async {
    await fetchCount();
  }
}
