import 'package:dllni_user_app/core/realtime/cleaning_realtime_contract.dart';
import 'package:dllni_user_app/features/orders/data/models/cleaning_booking_status.dart';

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

    final reopenCompletionAfterRefresh = _shouldReopenCompletionSheet(
      normalizedEvent: normalizedEvent,
      payload: payload,
      currentStatus: currentStatus,
    );

    return CleaningOrderRealtimeAction(
      type: CleaningOrderRealtimeActionType.refreshDetails,
      normalizedEvent: normalizedEvent,
      reopenCompletionAfterRefresh: reopenCompletionAfterRefresh,
    );
  }

  static bool _shouldReopenCompletionSheet({
    required String normalizedEvent,
    required Map<String, dynamic> payload,
    required String? currentStatus,
  }) {
    final normalizedCurrent = (currentStatus ?? '').trim().toLowerCase();
    if (normalizedCurrent == CleaningBookingStatus.timeExtensionRequested) {
      return false;
    }

    if (normalizedEvent == CleaningRealtimeContract.awaitingCustomerCompletion) {
      return true;
    }

    if (normalizedEvent == CleaningRealtimeContract.completionDecisionMade) {
      final unwrapped = CleaningRealtimeContract.unwrapPayload(payload);
      final decision = (CleaningRealtimeContract.extractDecision(unwrapped) ??
              unwrapped['decision']?.toString())
          ?.trim()
          .toLowerCase();
      if (decision == 'extension_rejected' ||
          decision == 'extension_accepted' ||
          decision == 'extension_requested') {
        return false;
      }
      if (decision == 'rejected' &&
          normalizedCurrent == CleaningBookingStatus.timeExtensionRequested) {
        return false;
      }
    }

    if (normalizedEvent == CleaningRealtimeContract.trackingUpdated &&
        normalizedCurrent == CleaningBookingStatus.timeExtensionRequested) {
      return false;
    }

    return false;
  }
}
