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

  Future<CleaningMultiDayOrderEnvelope> skipSession({
    required int orderId,
    required int sessionId,
    required String reason,
  }) {
    return _post(
      '/api/v1/cleaning-bookings/$orderId/sessions/$sessionId/skip',
      data: <String, dynamic>{'reason': reason.trim()},
    );
  }

  Future<CleaningMultiDayOrderEnvelope> pauseRecurringSeries({
    required int orderId,
    required String reason,
  }) {
    return _post(
      '/api/v1/cleaning-bookings/$orderId/recurring/pause',
      data: <String, dynamic>{'reason': reason.trim()},
    );
  }

  Future<CleaningMultiDayOrderEnvelope> resumeRecurringSeries({
    required int orderId,
  }) {
    return _post('/api/v1/cleaning-bookings/$orderId/recurring/resume');
  }

  Future<CleaningMultiDayOrderEnvelope> changeWorkers({
    required int orderId,
    required List<Map<String, dynamic>> changes,
    required String reason,
  }) {
    return _post(
      '/api/v1/cleaning-bookings/$orderId/sessions/change-workers',
      data: <String, dynamic>{'changes': changes, 'reason': reason.trim()},
    );
  }

  Future<CleaningMultiDayOrderEnvelope> reportSessionAttendance({
    required int orderId,
    required int sessionId,
    required List<int> workerIds,
    required String action,
    String? note,
  }) {
    final data = <String, dynamic>{'workerIds': workerIds, 'action': action};
    final normalizedNote = note?.trim();
    if (normalizedNote != null && normalizedNote.isNotEmpty) {
      data['note'] = normalizedNote;
    }

    return _post(
      '/api/v1/cleaning-bookings/$orderId/sessions/$sessionId/attendance',
      data: data,
    );
  }

  Future<CleaningMultiDayOrderEnvelope> submitSessionReview({
    required int orderId,
    required int sessionId,
    required int workerId,
    required int rating,
    String? comment,
  }) {
    final data = <String, dynamic>{'workerId': workerId, 'rating': rating};
    final normalizedComment = comment?.trim();
    if (normalizedComment != null && normalizedComment.isNotEmpty) {
      data['comment'] = normalizedComment;
    }

    return _post(
      '/api/v1/cleaning-bookings/$orderId/sessions/$sessionId/review',
      data: data,
    );
  }

  Future<CleaningMultiDayOrderEnvelope> openSessionDispute({
    required int orderId,
    required int sessionId,
    required String description,
    required String category,
  }) {
    return _post(
      '/api/v1/cleaning-bookings/$orderId/sessions/$sessionId/disputes',
      data: <String, dynamic>{
        'description': description.trim(),
        'category': category,
      },
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
    final data = <String, dynamic>{
      'emergency_type': emergencyType,
      'message': message.trim(),
    };
    if (latitude != null) data['latitude'] = latitude;
    if (longitude != null) data['longitude'] = longitude;

    return _post(
      '/api/v1/cleaning-bookings/$orderId/sessions/$sessionId/sos',
      data: data,
    );
  }

  Future<CleaningRecurringScheduleRevisionPreviewModel>
  previewRecurringScheduleRevision({
    required int orderId,
    required List<Map<String, dynamic>> sessions,
  }) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.postData(
        endPoint:
            '/api/v1/user/cleaning/orders/$orderId/recurring-schedule/preview',
        data: <String, dynamic>{
          'schedule': <String, dynamic>{
            'mode': 'recurring',
            'sessions': sessions,
          },
        },
      ),
      jsonConvert: cleaningRecurringScheduleRevisionPreviewFromJson,
    );
  }

  Future<CleaningMultiDayOrderEnvelope> confirmRecurringScheduleRevision({
    required int orderId,
    required List<Map<String, dynamic>> sessions,
    required String revisionToken,
  }) {
    return _post(
      '/api/v1/user/cleaning/orders/$orderId/recurring-schedule/confirm',
      data: <String, dynamic>{
        'schedule': <String, dynamic>{
          'mode': 'recurring',
          'sessions': sessions,
        },
        'revisionToken': revisionToken,
      },
    );
  }

  Future<CleaningMultiDayOrderEnvelope> updateSchedule({
    required int orderId,
    required List<Map<String, dynamic>> sessions,
  }) {
    return wrapHandlingApi(
      tryCall: () => dioNetwork.patchData(
        endPoint: '/api/v1/user/cleaning/orders/$orderId',
        data: <String, dynamic>{
          'schedule': <String, dynamic>{
            'mode': sessions.length > 1 ? 'multi_day' : 'single_day',
            'sessions': sessions,
          },
        },
      ),
      jsonConvert: cleaningMultiDayOrderEnvelopeFromJson,
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
