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

  CheckRestaurantCouponParams({
    required this.couponCode,
    this.section = 'restaurants',
  });

  @override
  BodyMap getBody() => {
        'section': section,
        'couponCode': couponCode,
      };
}
