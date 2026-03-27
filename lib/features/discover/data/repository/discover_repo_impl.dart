import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/error_handler.dart';

import '../../domain/repository/discover_repo.dart';

@LazySingleton(as: DiscoverRepo)
class DiscoverRepoImpl with HandlingException implements DiscoverRepo {}

