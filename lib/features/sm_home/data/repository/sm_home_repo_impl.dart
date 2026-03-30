import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/error_handler.dart';

import '../../domain/repository/sm_home_repo.dart';

@LazySingleton(as: SmHomeRepo)
class SmHomeRepoImpl with HandlingException implements SmHomeRepo {}

