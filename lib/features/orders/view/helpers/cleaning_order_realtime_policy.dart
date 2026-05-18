import 'package:dllni_user_app/core/realtime/cleaning_realtime_contract.dart';

import '../../data/models/cleaning_booking_status.dart';

enum CleaningOrderRealtimeActionType {
  ignore,
  patchWorkerLocation,
  refreshDetails,
}

class CleaningOrderRealtimeAction {
  const CleaningOrderRealtimeAction({
    required this.type,
    required this.normalizedEvent,
    this.reopenCompletionAfterRefresh = false,
  });

  final CleaningOrderRealtimeActionType type;
  final String normalizedEvent;
  final bool reopenCompletionAfterRefresh;
}

class CleaningOrderRealtimePolicy {
  CleaningOrderRealtimePolicy._();

  static CleaningOrderRealtimeAction resolve({
    required String eventName,
    required Map<String, dynamic> payload,
    required String? currentStatus,
  }) {
    final normalizedEvent = CleaningRealtimeContract.normalizeEventName(
      eventName,
    );

    if (CleaningRealtimeContract.isLocationEvent(normalizedEvent)) {
      return CleaningOrderRealtimeAction(
        type: CleaningOrderRealtimeActionType.patchWorkerLocation,
        normalizedEvent: normalizedEvent,
      );
    }

    if (!CleaningRealtimeContract.isLifecycleRefreshEvent(normalizedEvent)) {
      return CleaningOrderRealtimeAction(
        type: CleaningOrderRealtimeActionType.ignore,
        normalizedEvent: normalizedEvent,
      );
    }

    final normalizedStatus = (currentStatus ?? '').toLowerCase();
    var reopenCompletionAfterRefresh =
        normalizedEvent == CleaningRealtimeContract.awaitingCustomerCompletion;

    if (normalizedEvent == CleaningRealtimeContract.completionDecisionMade) {
      final decision = (payload['decision'] ?? payload['status'] ?? '')
          .toString()
          .toLowerCase();
      if (decision == 'rejected' &&
          normalizedStatus == CleaningBookingStatus.timeExtensionRequested) {
        reopenCompletionAfterRefresh = true;
      }
      if (decision == 'extension_rejected' ||
          decision == 'extension_declined' ||
          decision == 'worker_rejected_extension') {
        reopenCompletionAfterRefresh = true;
      }
    }

    if (normalizedEvent == CleaningRealtimeContract.trackingUpdated) {
      final tracking = payload['tracking'];
      final trackingMap = tracking is Map
          ? Map<String, dynamic>.from(tracking)
          : null;
      final nextStatus = (trackingMap?['status'] ?? '')
          .toString()
          .toLowerCase();
      if (nextStatus == CleaningBookingStatus.awaitingCustomerCompletion &&
          normalizedStatus == CleaningBookingStatus.timeExtensionRequested) {
        reopenCompletionAfterRefresh = true;
      }
    }

    return CleaningOrderRealtimeAction(
      type: CleaningOrderRealtimeActionType.refreshDetails,
      normalizedEvent: normalizedEvent,
      reopenCompletionAfterRefresh: reopenCompletionAfterRefresh,
    );
  }
}
