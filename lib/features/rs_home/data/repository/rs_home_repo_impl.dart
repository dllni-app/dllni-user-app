import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/error_handler.dart';

import '../../domain/repository/rs_home_repo.dart';

@LazySingleton(as: RsHomeRepo)
class RsHomeRepoImpl with HandlingException implements RsHomeRepo {}

