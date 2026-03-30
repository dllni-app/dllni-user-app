import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/error_handler.dart';

import '../../domain/repository/cl_home_repo.dart';

@LazySingleton(as: ClHomeRepo)
class ClHomeRepoImpl with HandlingException implements ClHomeRepo {}

