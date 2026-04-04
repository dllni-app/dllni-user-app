import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/rs_orders_api_models.dart';
import '../repository/rs_orders_repo.dart';

@lazySingleton
class CheckoutOrderUseCase
    implements UseCase<CheckoutOrderModel, CheckoutOrderParams> {
  final RsOrdersRepo rsOrdersRepo;

  CheckoutOrderUseCase({required this.rsOrdersRepo});

  @override
  DataResponse<CheckoutOrderModel> call(CheckoutOrderParams params) {
    return rsOrdersRepo.checkout(
      restaurantId: params.restaurantId,
      orderType: params.orderType,
      pickupMode: params.pickupMode,
      pickupScheduledFor: params.pickupScheduledFor,
      promoCode: params.promoCode,
      specialInstructions: params.specialInstructions,
    );
  }
}

class CheckoutOrderParams with Params {
  final int restaurantId;
  final String orderType;
  final String pickupMode;
  final String? pickupScheduledFor;
  final String? promoCode;
  final String specialInstructions;

  CheckoutOrderParams({
    required this.restaurantId,
    required this.orderType,
    this.pickupMode = 'immediate_pickup',
    this.pickupScheduledFor,
    this.promoCode,
    this.specialInstructions = '',
  });

  @override
  BodyMap getBody() => {
    'restaurantId': restaurantId,
    'orderType': orderType,
    'pickupMode': pickupMode,
    if (pickupScheduledFor != null) 'pickupScheduledFor': pickupScheduledFor,
    if (promoCode != null) 'promoCode': promoCode,
    'specialInstructions': specialInstructions,
  };
}
