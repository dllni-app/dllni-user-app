import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/error_handler.dart';

import '../../domain/repository/cl_offers_repo.dart';

@LazySingleton(as: ClOffersRepo)
class ClOffersRepoImpl with HandlingException implements ClOffersRepo {}

