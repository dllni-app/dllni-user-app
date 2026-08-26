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
        endPoint: '/api/v1/user/cleaning/orders/$orderId',
      ),
      jsonConvert: cleaningMultiDayOrderEnvelopeFromJson,
    );
  }

  Future<CleaningMultiDayOrderEnvelope> confirmStartVerification({
    required int orderId,
    required int sessionId,
    required String code,
  }) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint:
            '/api/v1/user/cleaning/orders/$orderId/sessions/$sessionId/start-verification/confirm',
        data: <String, dynamic>{'code': code},
      ),
      jsonConvert: cleaningMultiDayOrderEnvelopeFromJson,
    );
  }

  Future<CleaningMultiDayOrderEnvelope> confirmCompletion({
    required int orderId,
    required int sessionId,
    int? workerId,
    int? assignmentId,
  }) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint:
            '/api/v1/user/cleaning/orders/$orderId/sessions/$sessionId/completion/confirm',
        data: <String, dynamic>{
          if (workerId != null) 'workerId': workerId,
          if (assignmentId != null) 'assignmentId': assignmentId,
        },
      ),
      jsonConvert: cleaningMultiDayOrderEnvelopeFromJson,
    );
  }

  Future<CleaningMultiDayOrderEnvelope> rejectCompletion({
    required int orderId,
    required int sessionId,
    required String message,
    int? workerId,
    int? assignmentId,
  }) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint:
            '/api/v1/user/cleaning/orders/$orderId/sessions/$sessionId/completion/reject',
        data: <String, dynamic>{
          'message': message,
          if (workerId != null) 'workerId': workerId,
          if (assignmentId != null) 'assignmentId': assignmentId,
        },
      ),
      jsonConvert: cleaningMultiDayOrderEnvelopeFromJson,
    );
  }

  Future<CleaningMultiDayOrderEnvelope> requestExtension({
    required int orderId,
    required int sessionId,
    required int additionalMinutes,
    String? message,
    int? workerId,
    int? assignmentId,
  }) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint:
            '/api/v1/user/cleaning/orders/$orderId/sessions/$sessionId/completion/extend-time',
        data: <String, dynamic>{
          'additionalMinutes': additionalMinutes,
          if (message != null && message.trim().isNotEmpty)
            'message': message.trim(),
          if (workerId != null) 'workerId': workerId,
          if (assignmentId != null) 'assignmentId': assignmentId,
        },
      ),
      jsonConvert: cleaningMultiDayOrderEnvelopeFromJson,
    );
  }

  Future<CleaningMultiDayOrderEnvelope> cancelSession({
    required int orderId,
    required int sessionId,
    required String reason,
  }) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint:
            '/api/v1/user/cleaning/orders/$orderId/sessions/$sessionId/cancel',
        data: <String, dynamic>{'reason': reason.trim()},
      ),
      jsonConvert: cleaningMultiDayOrderEnvelopeFromJson,
    );
  }
}
