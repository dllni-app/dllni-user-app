import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/error_handler.dart';

import '../../domain/repository/sm_orders_repo.dart';

@LazySingleton(as: SmOrdersRepo)
class SmOrdersRepoImpl with HandlingException implements SmOrdersRepo {}

