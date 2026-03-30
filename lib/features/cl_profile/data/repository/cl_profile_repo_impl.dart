import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/error_handler.dart';

import '../../domain/repository/cl_profile_repo.dart';

@LazySingleton(as: ClProfileRepo)
class ClProfileRepoImpl with HandlingException implements ClProfileRepo {}

