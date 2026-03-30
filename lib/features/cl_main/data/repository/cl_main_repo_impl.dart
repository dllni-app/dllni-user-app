import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/error_handler.dart';

import '../../domain/repository/cl_main_repo.dart';

@LazySingleton(as: ClMainRepo)
class ClMainRepoImpl with HandlingException implements ClMainRepo {}

