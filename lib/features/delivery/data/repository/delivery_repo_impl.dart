import 'package:common_package/helpers/error_handler.dart';
import 'package:common_package/helpers/typedef.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repository/delivery_repo.dart';
import '../../domain/usecases/fetch_delivery_order_details_use_case.dart';
import '../../domain/usecases/fetch_delivery_orders_use_case.dart';
import '../models/delivery_order_models.dart';
import '../source/delivery_remote_data_source.dart';

@LazySingleton(as: DeliveryRepo)
class DeliveryRepoImpl with HandlingException implements DeliveryRepo {
  DeliveryRepoImpl({required this.deliveryRemoteDataSource});

  final DeliveryRemoteDataSource deliveryRemoteDataSource;

  @override
  DataResponse<FetchDeliveryOrdersModel> fetchDeliveryOrders(
    FetchDeliveryOrdersParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => deliveryRemoteDataSource.fetchDeliveryOrders(params),
    );
  }

  @override
  DataResponse<FetchDeliveryOrderDetailsModel> fetchDeliveryOrderDetails(
    FetchDeliveryOrderDetailsParams params,
  ) {
    return wrapHandlingException(
      tryCall: () => deliveryRemoteDataSource.fetchDeliveryOrderDetails(params),
    );
  }
}
