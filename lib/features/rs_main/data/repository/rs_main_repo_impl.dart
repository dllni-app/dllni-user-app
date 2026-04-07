import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/error_handler.dart';

import '../../domain/repository/rs_main_repo.dart';

@LazySingleton(as: RsMainRepo)
class RsMainRepoImpl with HandlingException implements RsMainRepo {}

