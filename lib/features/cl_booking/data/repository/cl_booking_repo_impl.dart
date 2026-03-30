import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/error_handler.dart';

import '../../domain/repository/cl_booking_repo.dart';

@LazySingleton(as: ClBookingRepo)
class ClBookingRepoImpl with HandlingException implements ClBookingRepo {}

