import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/orders_api_models.dart';
import '../repository/orders_repo.dart';

@lazySingleton
class CheckRestaurantCouponUseCase
    implements UseCase<CouponCheckModel, CheckRestaurantCouponParams> {
  final OrdersRepo ordersRepo;

  CheckRestaurantCouponUseCase({required this.ordersRepo});

  @override
  DataResponse<CouponCheckModel> call(CheckRestaurantCouponParams params) {
    return ordersRepo.checkRestaurantCoupon(params);
  }
}

class CheckRestaurantCouponParams with Params {
  final String couponCode;
  final String section;
  final int? cartId;
  final String? propertyType;
  final Map<String, dynamic>? propertyDetails;
  final double? addressLatitude;
  final double? addressLongitude;
  final int? preferredWorkerId;

  CheckRestaurantCouponParams({
    required this.couponCode,
    this.section = 'restaurant',
    this.cartId,
    this.propertyType,
    this.propertyDetails,
    this.addressLatitude,
    this.addressLongitude,
    this.preferredWorkerId,
  });

  @override
  BodyMap getBody() => {
        'section': section,
        'couponCode': couponCode.trim(),
        if (cartId != null) 'cartId': cartId,
        if (propertyType != null) 'propertyType': propertyType,
        if (propertyDetails != null) 'propertyDetails': propertyDetails,
        if (addressLatitude != null) 'addressLatitude': addressLatitude,
        if (addressLongitude != null) 'addressLongitude': addressLongitude,
        if (preferredWorkerId != null) 'preferredWorkerId': preferredWorkerId,
      };
}
