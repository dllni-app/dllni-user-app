import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/orders_api_models.dart';
import '../repository/orders_repo.dart';

@lazySingleton
class PlaceRestaurantOrderUseCase implements UseCase<PlaceRestaurantOrderModel, PlaceRestaurantOrderParams> {
  final OrdersRepo ordersRepo;

  PlaceRestaurantOrderUseCase({required this.ordersRepo});

  @override
  DataResponse<PlaceRestaurantOrderModel> call(PlaceRestaurantOrderParams params) {
    return ordersRepo.placeRestaurantOrder(params);
  }
}

class PlaceRestaurantOrderParams with Params {
  final String fulfillmentType;
  final int? addressId;
  final String? couponCode;
  final String? note;

  PlaceRestaurantOrderParams({required this.fulfillmentType, this.addressId, this.couponCode, this.note});

  @override
  BodyMap getBody() {
    final normalizedFulfillmentType = fulfillmentType == 'pickup' ? 'dine_in' : fulfillmentType;

    return <String, dynamic>{
      'fulfillmentType': normalizedFulfillmentType,
      'addressId': addressId,
      'couponCode': couponCode,
      'note': note,
      'receiveMode': 'immediate',
    };
  }
}
