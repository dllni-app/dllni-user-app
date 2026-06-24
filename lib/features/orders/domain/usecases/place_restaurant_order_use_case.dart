import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/orders_api_models.dart';
import '../repository/orders_repo.dart';

@lazySingleton
class PlaceRestaurantOrderUseCase
    implements UseCase<PlaceRestaurantOrderModel, PlaceRestaurantOrderParams> {
  final OrdersRepo ordersRepo;

  PlaceRestaurantOrderUseCase({required this.ordersRepo});

  @override
  DataResponse<PlaceRestaurantOrderModel> call(
    PlaceRestaurantOrderParams params,
  ) {
    return ordersRepo.placeRestaurantOrder(params);
  }
}

class PlaceRestaurantOrderParams with Params {
  final int cartId;
  final String fulfillmentType;
  final String receiveMode;
  final String? scheduledAt;
  final int? addressId;
  final String? couponCode;
  final String? note;

  PlaceRestaurantOrderParams({
    required this.cartId,
    required this.fulfillmentType,
    this.receiveMode = 'immediate',
    this.scheduledAt,
    this.addressId,
    this.couponCode,
    this.note,
  });

  @override
  BodyMap getBody() {
    final normalizedFulfillmentType = fulfillmentType == 'pickup'
        ? 'dine_in'
        : fulfillmentType;
    final body = <String, dynamic>{
      'fulfillmentType': normalizedFulfillmentType,
      'receiveMode': receiveMode,
      'addressId': addressId,
    };

    if (receiveMode == 'scheduled' && (scheduledAt?.isNotEmpty ?? false)) {
      body['scheduledAt'] = scheduledAt;
    }
    if (couponCode != null && couponCode!.trim().isNotEmpty) {
      body['couponCode'] = couponCode;
    }
    if (note != null && note!.trim().isNotEmpty) {
      body['note'] = note;
    }

    return body;
  }
}
