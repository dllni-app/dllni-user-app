import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/error_handler.dart';

import '../../domain/repository/sm_profile_repo.dart';

@LazySingleton(as: SmProfileRepo)
class SmProfileRepoImpl with HandlingException implements SmProfileRepo {}

