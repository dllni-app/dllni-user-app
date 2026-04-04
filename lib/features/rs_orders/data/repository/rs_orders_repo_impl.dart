import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/error_handler.dart';
import 'package:common_package/helpers/typedef.dart';

import '../../data/models/rs_orders_api_models.dart';
import '../../domain/repository/rs_orders_repo.dart';
import '../source/rs_orders_remote_data_source.dart';

@LazySingleton(as: RsOrdersRepo)
class RsOrdersRepoImpl with HandlingException implements RsOrdersRepo {
  final RsOrdersRemoteDataSource rsOrdersRemoteDataSource;

  RsOrdersRepoImpl({required this.rsOrdersRemoteDataSource});

  @override
  DataResponse<FetchOrdersListModel> listOrders({int page = 1, int perPage = 20}) {
    return wrapHandlingException(
      tryCall: () => rsOrdersRemoteDataSource.listOrders(page: page, perPage: perPage),
    );
  }

  @override
  DataResponse<FetchOrderDetailsModel> showOrder({required int orderId}) {
    return wrapHandlingException(
      tryCall: () => rsOrdersRemoteDataSource.showOrder(orderId: orderId),
    );
  }

  @override
  DataResponse<CheckoutOrderModel> checkout({
    required int restaurantId,
    required String orderType,
    String pickupMode = 'immediate_pickup',
    String? pickupScheduledFor,
    String? promoCode,
    String specialInstructions = '',
  }) {
    return wrapHandlingException(
      tryCall: () => rsOrdersRemoteDataSource.checkout(
        restaurantId: restaurantId,
        orderType: orderType,
        pickupMode: pickupMode,
        pickupScheduledFor: pickupScheduledFor,
        promoCode: promoCode,
        specialInstructions: specialInstructions,
      ),
    );
  }

  @override
  DataResponse<AddCartItemModel> addCartItem({
    required int productId,
    int quantity = 1,
    List<int> modifierIds = const [],
    int? substituteProductId,
    String specialInstructions = '',
  }) {
    return wrapHandlingException(
      tryCall: () => rsOrdersRemoteDataSource.addCartItem(
        productId: productId,
        quantity: quantity,
        modifierIds: modifierIds,
        substituteProductId: substituteProductId,
        specialInstructions: specialInstructions,
      ),
    );
  }
}

