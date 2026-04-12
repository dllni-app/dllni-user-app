import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/orders_api_models.dart';
import '../repository/orders_repo.dart';

@lazySingleton
class PlaceStoreOrderUseCase
    implements UseCase<PlaceRestaurantOrderModel, PlaceStoreOrderParams> {
  final OrdersRepo ordersRepo;

  PlaceStoreOrderUseCase({required this.ordersRepo});

  @override
  DataResponse<PlaceRestaurantOrderModel> call(PlaceStoreOrderParams params) {
    return ordersRepo.placeStoreOrder(params);
  }
}

class PlaceStoreOrderParams with Params {
  final int merchantId;
  final String fulfillmentType;
  final String receiveMode;
  final String? scheduledAt;
  final int? addressId;
  final String? couponCode;
  final String? note;

  PlaceStoreOrderParams({
    required this.merchantId,
    required this.fulfillmentType,
    required this.receiveMode,
    this.scheduledAt,
    this.addressId,
    this.couponCode,
    this.note,
  });

  @override
  BodyMap getBody() {
    final body = <String, dynamic>{
      'merchantId': merchantId,
      'fulfillmentType': fulfillmentType,
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
