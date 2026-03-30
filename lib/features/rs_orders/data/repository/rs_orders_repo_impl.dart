import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/error_handler.dart';

import '../../domain/repository/rs_orders_repo.dart';

@LazySingleton(as: RsOrdersRepo)
class RsOrdersRepoImpl with HandlingException implements RsOrdersRepo {}

