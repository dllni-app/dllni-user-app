import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/error_handler.dart';

import '../../domain/repository/rs_discover_repo.dart';

@LazySingleton(as: RsDiscoverRepo)
class RsDiscoverRepoImpl with HandlingException implements RsDiscoverRepo {}

