import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/error_handler.dart';

import '../../domain/repository/sm_cart_repo.dart';

@LazySingleton(as: SmCartRepo)
class SmCartRepoImpl with HandlingException implements SmCartRepo {}

