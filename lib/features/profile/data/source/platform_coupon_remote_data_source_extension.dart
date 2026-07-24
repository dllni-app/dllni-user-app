import 'package:common_package/common_package.dart';

import '../models/platform_coupon_models.dart';
import '../models/profile_api_models.dart';
import 'profile_remote_data_source.dart';

extension PlatformCouponRemoteDataSourceExtension on ProfileRemoteDataSource {
  Future<FetchCouponsModel> fetchPlatformCoupons(NoParams params) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/user/coupons',
        params: params.getParams(),
        data: params.getBody().isEmpty ? null : params.getBody(),
      ),
      jsonConvert: fetchPlatformCouponsModelFromJson,
    );
  }
}
