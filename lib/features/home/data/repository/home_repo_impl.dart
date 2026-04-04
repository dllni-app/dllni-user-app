import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/error_handler.dart';

import '../../domain/repository/home_repo.dart';

@LazySingleton(as: HomeRepo)
class HomeRepoImpl with HandlingException implements HomeRepo {}

