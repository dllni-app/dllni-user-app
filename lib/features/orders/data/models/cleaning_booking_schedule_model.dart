import 'dart:convert';

Map<String, dynamic> _scheduleMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), val));
  }
  return const <String, dynamic>{};
}

int? _scheduleInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

bool _scheduleBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = value?.toString().trim().toLowerCase();
  return normalized == 'true' || normalized == '1';
}

String? _scheduleString(dynamic value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

List<int> _scheduleIntList(dynamic value) {
  if (value is! List) return const <int>[];
  return value
      .map(_scheduleInt)
      .whereType<int>()
      .toList(growable: false);
}

class CleaningSessionWorkerAssignmentModel {
  const CleaningSessionWorkerAssignmentModel({
    this.id,
    this.workerId,
    this.status,
  });

  final int? id;
  final int? workerId;
  final String? status;

  factory CleaningSessionWorkerAssignmentModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CleaningSessionWorkerAssignmentModel(
      id: _scheduleInt(json['id']),
      workerId: _scheduleInt(json['workerId'] ?? json['worker_id']),
      status: _scheduleString(json['status']),
    );
  }
}

class CleaningBookingSessionModel {
  const CleaningBookingSessionModel({
    this.id,
    required this.status,
    this.date,
    this.time,
    this.canConfirmStartVerification = false,
    this.canConfirmCompletion = false,
    this.canReview = false,
    this.hasReview = false,
    this.reviewableWorkerIds = const <int>[],
    this.workerAssignments = const <CleaningSessionWorkerAssignmentModel>[],
    this.workerAssignmentState,
  });

  final int? id;
  final String status;
  final DateTime? date;
  final String? time;
  final bool canConfirmStartVerification;
  final bool canConfirmCompletion;
  final bool canReview;
  final bool hasReview;
  final List<int> reviewableWorkerIds;
  final List<CleaningSessionWorkerAssignmentModel> workerAssignments;
  final CleaningSessionWorkerAssignmentModel? workerAssignmentState;

  factory CleaningBookingSessionModel.fromJson(Map<String, dynamic> json) {
    final assignmentsRaw = json['workerAssignments'] ?? json['worker_assignments'];
    final assignments = assignmentsRaw is List
        ? assignmentsRaw
              .map((item) => CleaningSessionWorkerAssignmentModel.fromJson(
                    _scheduleMap(item),
                  ))
              .toList(growable: false)
        : const <CleaningSessionWorkerAssignmentModel>[];
    final assignmentStateRaw =
        json['workerAssignmentState'] ??
        json['worker_assignment_state'] ??
        json['myWorkerAssignment'] ??
        json['myAssignment'];

    return CleaningBookingSessionModel(
      id: _scheduleInt(json['id'] ?? json['sessionId'] ?? json['session_id']),
      status: _scheduleString(json['status']) ?? '',
      date: DateTime.tryParse(
        _scheduleString(json['date'] ?? json['scheduledDate'] ?? json['scheduled_date']) ??
            '',
      ),
      time: _scheduleString(
        json['time'] ?? json['scheduledTime'] ?? json['scheduled_time'],
      ),
      canConfirmStartVerification: _scheduleBool(
        json['canConfirmStartVerification'] ??
            json['can_confirm_start_verification'],
      ),
      canConfirmCompletion: _scheduleBool(
        json['canConfirmCompletion'] ?? json['can_confirm_completion'],
      ),
      canReview: _scheduleBool(json['canReview'] ?? json['can_review']),
      hasReview: _scheduleBool(json['hasReview'] ?? json['has_review']),
      reviewableWorkerIds: _scheduleIntList(
        json['reviewableWorkerIds'] ?? json['reviewable_worker_ids'],
      ),
      workerAssignments: assignments,
      workerAssignmentState: assignmentStateRaw is Map
          ? CleaningSessionWorkerAssignmentModel.fromJson(
              _scheduleMap(assignmentStateRaw),
            )
          : null,
    );
  }

  bool get isAwaitingCustomerCompletion =>
      status == 'awaiting_customer_completion';

  bool get isCompleted => status == 'completed';
}

class CleaningBookingScheduleModel {
  const CleaningBookingScheduleModel({
    this.sessions = const <CleaningBookingSessionModel>[],
  });

  final List<CleaningBookingSessionModel> sessions;

  factory CleaningBookingScheduleModel.fromJson(Map<String, dynamic> json) {
    final raw = json['sessions'];
    return CleaningBookingScheduleModel(
      sessions: raw is List
          ? raw
                .map(
                  (item) => CleaningBookingSessionModel.fromJson(
                    _scheduleMap(item),
                  ),
                )
                .toList(growable: false)
          : const <CleaningBookingSessionModel>[],
    );
  }
}

class CleaningMultiDayOrderEnvelope {
  const CleaningMultiDayOrderEnvelope({
    this.bookingId,
    this.status,
    this.schedule,
  });

  final int? bookingId;
  final String? status;
  final CleaningBookingScheduleModel? schedule;

  factory CleaningMultiDayOrderEnvelope.fromJson(Map<String, dynamic> root) {
    final data = root['data'] is Map ? _scheduleMap(root['data']) : root;
    final scheduleRaw = data['schedule'];
    return CleaningMultiDayOrderEnvelope(
      bookingId: _scheduleInt(
        data['bookingId'] ?? data['booking_id'] ?? data['id'],
      ),
      status: _scheduleString(data['status']),
      schedule: scheduleRaw is Map
          ? CleaningBookingScheduleModel.fromJson(_scheduleMap(scheduleRaw))
          : null,
    );
  }
}

CleaningMultiDayOrderEnvelope cleaningMultiDayOrderEnvelopeFromJson(
  dynamic json,
) {
  final decoded = json is String ? jsonDecode(json) : json;
  return CleaningMultiDayOrderEnvelope.fromJson(_scheduleMap(decoded));
}
