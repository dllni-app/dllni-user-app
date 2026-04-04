import 'package:common_package/helpers/typedef.dart';

import '../../data/models/rs_orders_api_models.dart';

abstract class RsOrdersRepo {
  DataResponse<FetchOrdersListModel> listOrders({int page = 1, int perPage = 20});

  DataResponse<FetchOrderDetailsModel> showOrder({required int orderId});

  DataResponse<CheckoutOrderModel> checkout({
    required int restaurantId,
    required String orderType,
    String pickupMode = 'immediate_pickup',
    String? pickupScheduledFor,
    String? promoCode,
    String specialInstructions = '',
  });

  DataResponse<AddCartItemModel> addCartItem({
    required int productId,
    int quantity = 1,
    List<int> modifierIds = const [],
    int? substituteProductId,
    String specialInstructions = '',
  });
}
