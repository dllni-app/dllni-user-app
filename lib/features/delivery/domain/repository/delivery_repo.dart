import 'package:common_package/helpers/typedef.dart';

import '../../data/models/delivery_order_models.dart';
import '../usecases/fetch_delivery_order_details_use_case.dart';
import '../usecases/fetch_delivery_orders_use_case.dart';

abstract class DeliveryRepo {
  DataResponse<FetchDeliveryOrdersModel> fetchDeliveryOrders(
    FetchDeliveryOrdersParams params,
  );

  DataResponse<FetchDeliveryOrderDetailsModel> fetchDeliveryOrderDetails(
    FetchDeliveryOrderDetailsParams params,
  );
}
