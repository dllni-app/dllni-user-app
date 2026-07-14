import 'package:dllni_user_app/core/realtime/cleaning_realtime_contract.dart';
import 'package:dllni_user_app/features/orders/data/models/cleaning_booking_status.dart';

class CleaningExtensionRejectedDialogData {
  const CleaningExtensionRejectedDialogData({
    required this.message,
    this.warningId,
  });

  final int? warningId;
  final String message;
}

class CleaningExtensionDecisionPresenter {
  CleaningExtensionDecisionPresenter._();

  static const Set<String> _rejectedDecisions = <String>{
    'extension_rejected',
    'extension_declined',
    'worker_rejected_extension',
  };

  static CleaningExtensionRejectedDialogData? resolveRejectedDialog({
    required String normalizedEvent,
    required Map<String, dynamic> payload,
    required String? currentStatus,
    required Set<int> handledWarningIds,
  }) {
    if (normalizedEvent != CleaningRealtimeContract.completionDecisionMade &&
        normalizedEvent != CleaningRealtimeContract.trackingUpdated) {
      return null;
    }
    final normalizedStatus = (currentStatus ?? '').trim().toLowerCase();
    if (normalizedStatus != CleaningBookingStatus.timeExtensionRequested) {
      return null;
    }

    final unwrapped = CleaningRealtimeContract.unwrapPayload(payload);
    final decision = _extractDecision(normalizedEvent, unwrapped);
    if (!_rejectedDecisions.contains(decision)) {
      return null;
    }

    final warningId = _extractWarningId(unwrapped);
    if (warningId != null && handledWarningIds.contains(warningId)) {
      return null;
    }

    final message = _extractMessage(unwrapped);
    return CleaningExtensionRejectedDialogData(
      warningId: warningId,
      message: message.isEmpty
          ? 'قام مقدم الخدمة برفض طلب تمديد الوقت وتم إنهاء الطلب.'
          : message,
    );
  }

  static String _extractDecision(
    String normalizedEvent,
    Map<String, dynamic> payload,
  ) {
    if (normalizedEvent == CleaningRealtimeContract.completionDecisionMade) {
      return CleaningRealtimeContract.extractDecision(payload) ?? '';
    }

    final tracking = payload['tracking'];
    final trackingMap = tracking is Map
        ? Map<String, dynamic>.from(tracking)
        : const <String, dynamic>{};
    return (trackingMap['decision'] ?? payload['decision'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
  }

  static int? _extractWarningId(Map<String, dynamic> payload) {
    final candidates = <dynamic>[payload['warningId'], payload['warning_id']];
    final tracking = payload['tracking'];
    if (tracking is Map) {
      final trackingMap = Map<String, dynamic>.from(tracking);
      candidates.addAll(<dynamic>[
        trackingMap['warningId'],
        trackingMap['warning_id'],
      ]);
    }
    for (final candidate in candidates) {
      if (candidate is int) return candidate;
      if (candidate is num) return candidate.toInt();
      final parsed = int.tryParse(candidate?.toString() ?? '');
      if (parsed != null) return parsed;
    }
    return null;
  }

  static String _extractMessage(Map<String, dynamic> payload) {
    final tracking = payload['tracking'];
    final trackingMap = tracking is Map
        ? Map<String, dynamic>.from(tracking)
        : const <String, dynamic>{};
    final message =
        payload['message'] ??
        payload['completionMessage'] ??
        payload['completion_message'] ??
        payload['workerRejectMessage'] ??
        payload['worker_reject_message'] ??
        trackingMap['message'];
    return message?.toString().trim() ?? '';
  }
}
