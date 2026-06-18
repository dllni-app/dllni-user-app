import 'package:common_package/helpers/api_handler.dart';
import 'package:common_package/helpers/dio_network.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/fetch_delivery_order_details_use_case.dart';
import '../../domain/usecases/fetch_delivery_orders_use_case.dart';
import '../models/delivery_order_models.dart';

@lazySingleton
class DeliveryRemoteDataSource with HandlingApiManager {
  DeliveryRemoteDataSource({required this.dioNetwork});

  final DioNetwork dioNetwork;

  Future<FetchDeliveryOrdersModel> fetchDeliveryOrders(
    FetchDeliveryOrdersParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/delivery/user/orders',
        params: params.getParams(),
      ),
      jsonConvert: fetchDeliveryOrdersModelFromJson,
    );
  }

  Future<FetchDeliveryOrderDetailsModel> fetchDeliveryOrderDetails(
    FetchDeliveryOrderDetailsParams params,
  ) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/delivery/user/orders/${params.orderId}',
      ),
      jsonConvert: fetchDeliveryOrderDetailsModelFromJson,
    );
  }
}
