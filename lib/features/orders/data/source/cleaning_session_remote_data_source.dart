import 'package:common_package/helpers/api_handler.dart';
import 'package:common_package/helpers/dio_network.dart';
import 'package:injectable/injectable.dart';

import '../models/cleaning_booking_schedule_model.dart';

@lazySingleton
class CleaningSessionRemoteDataSource with HandlingApiManager {
  final DioNetwork dioNetwork;

  CleaningSessionRemoteDataSource({required this.dioNetwork});

  Future<CleaningMultiDayOrderEnvelope> fetchBookingSchedule(int orderId) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/cleaning-bookings/$orderId/schedule',
      ),
      jsonConvert: cleaningMultiDayOrderEnvelopeFromJson,
    );
  }
}
