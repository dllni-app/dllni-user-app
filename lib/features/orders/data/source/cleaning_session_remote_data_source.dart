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

  Future<CleaningMultiDayOrderEnvelope> cancelSession({
    required int orderId,
    required int sessionId,
    required String reason,
  }) {
    return _post(
      '/api/v1/cleaning-bookings/$orderId/sessions/$sessionId/cancel',
      data: <String, dynamic>{'reason': reason.trim()},
    );
  }

  Future<CleaningMultiDayOrderEnvelope> sendSos({
    required int orderId,
    required int sessionId,
    required String emergencyType,
    required String message,
    double? latitude,
    double? longitude,
  }) {
    return _post(
      '/api/v1/cleaning-bookings/$orderId/sessions/$sessionId/sos',
      data: <String, dynamic>{
        'emergency_type': emergencyType,
        'message': message.trim(),
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      },
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
