import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/error_handler.dart';

import '../../domain/repository/sm_stores_repo.dart';

@LazySingleton(as: SmStoresRepo)
class SmStoresRepoImpl with HandlingException implements SmStoresRepo {}

