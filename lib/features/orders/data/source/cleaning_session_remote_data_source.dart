import 'package:common_package/helpers/api_handler.dart';
import 'package:common_package/helpers/dio_network.dart';

import '../models/cleaning_booking_schedule_model.dart';

class CleaningSessionRemoteDataSource with HandlingApiManager {
  CleaningSessionRemoteDataSource({required this.dioNetwork});

  final DioNetwork dioNetwork;

  Future<CleaningMultiDayOrderEnvelope> fetchBookingSchedule(int orderId) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.getData(
        endPoint: '/api/v1/cleaning-bookings/$orderId/schedule',
      ),
      jsonConvert: cleaningMultiDayOrderEnvelopeFromJson,
    );
  }

  Future<CleaningMultiDayOrderEnvelope> confirmStartVerification({
    required int orderId,
    required int sessionId,
    required String code,
  }) {
    return _post(
      '/api/v1/cleaning-bookings/$orderId/sessions/$sessionId/start-verification/confirm',
      data: <String, dynamic>{'code': code.trim()},
    );
  }

  Future<CleaningMultiDayOrderEnvelope> confirmCompletion({
    required int orderId,
    required int sessionId,
  }) {
    return _post(
      '/api/v1/cleaning-bookings/$orderId/sessions/$sessionId/completion/confirm',
    );
  }

  Future<CleaningMultiDayOrderEnvelope> _post(
    String endpoint, {
    Map<String, dynamic>? data,
  }) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint: endpoint,
        data: data ?? const <String, dynamic>{},
      ),
      jsonConvert: cleaningMultiDayOrderEnvelopeFromJson,
    );
  }
}
