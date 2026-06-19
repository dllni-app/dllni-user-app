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

    final reopenCompletionAfterRefresh =
        normalizedEvent == CleaningRealtimeContract.awaitingCustomerCompletion;

    return CleaningOrderRealtimeAction(
      type: CleaningOrderRealtimeActionType.refreshDetails,
      normalizedEvent: normalizedEvent,
      reopenCompletionAfterRefresh: reopenCompletionAfterRefresh,
    );
  }
}
