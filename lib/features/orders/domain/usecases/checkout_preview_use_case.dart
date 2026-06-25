import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/merchant_cart_models.dart';
import '../repository/orders_repo.dart';

@lazySingleton
class PreviewRestaurantCheckoutUseCase
    implements UseCase<CheckoutPreviewModel, CheckoutPreviewParams> {
  final OrdersRepo ordersRepo;

  PreviewRestaurantCheckoutUseCase({required this.ordersRepo});

  @override
  DataResponse<CheckoutPreviewModel> call(CheckoutPreviewParams params) {
    return ordersRepo.previewRestaurantCheckout(params);
  }
}

@lazySingleton
class PreviewStoreCheckoutUseCase
    implements UseCase<CheckoutPreviewModel, CheckoutPreviewParams> {
  final OrdersRepo ordersRepo;

  PreviewStoreCheckoutUseCase({required this.ordersRepo});

  @override
  DataResponse<CheckoutPreviewModel> call(CheckoutPreviewParams params) {
    return ordersRepo.previewStoreCheckout(params);
  }
}
