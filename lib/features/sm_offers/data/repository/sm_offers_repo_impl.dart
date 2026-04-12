import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/error_handler.dart';

import '../../domain/repository/sm_offers_repo.dart';

@LazySingleton(as: SmOffersRepo)
class SmOffersRepoImpl with HandlingException implements SmOffersRepo {}

