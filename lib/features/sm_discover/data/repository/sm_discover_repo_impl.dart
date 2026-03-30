import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/error_handler.dart';

import '../../domain/repository/sm_discover_repo.dart';

@LazySingleton(as: SmDiscoverRepo)
class SmDiscoverRepoImpl with HandlingException implements SmDiscoverRepo {}

