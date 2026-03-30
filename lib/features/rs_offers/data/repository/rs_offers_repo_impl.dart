import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/error_handler.dart';

import '../../domain/repository/rs_offers_repo.dart';

@LazySingleton(as: RsOffersRepo)
class RsOffersRepoImpl with HandlingException implements RsOffersRepo {}

