import 'package:common_package/helpers/error_handler.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repository/orders_repo.dart';

@LazySingleton(as: OrdersRepo)
class OrdersRepoImpl with HandlingException implements OrdersRepo {}
