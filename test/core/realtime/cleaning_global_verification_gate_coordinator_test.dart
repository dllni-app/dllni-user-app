import 'package:dllni_user_app/core/realtime/cleaning_global_verification_gate_coordinator.dart';
import 'package:dllni_user_app/features/orders/data/models/cleaning_booking_status.dart';
import 'package:dllni_user_app/features/orders/data/models/cleaning_orders_api_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CleaningGlobalVerificationGateCoordinator', () {
    test('findAwaitingVerificationOrderIds filters by status', () {
      final ids =
          CleaningGlobalVerificationGateCoordinator.findAwaitingVerificationOrderIds(
            <CleaningOrderModel>[
              CleaningOrderModel(
                id: 1,
                status: CleaningBookingStatus.workerAssigned,
              ),
              CleaningOrderModel(
                id: 2,
                status: CleaningBookingStatus.awaitingStartVerification,
              ),
              CleaningOrderModel(id: 3, status: 'AWAITING_START_VERIFICATION'),
            ],
          );

      expect(ids, <int>[2, 3]);
    });

    test('findAwaitingCompletionOrderIds filters by status', () {
      final ids =
          CleaningGlobalVerificationGateCoordinator.findAwaitingCompletionOrderIds(
            <CleaningOrderModel>[
              CleaningOrderModel(
                id: 1,
                status: CleaningBookingStatus.inProgress,
              ),
              CleaningOrderModel(
                id: 2,
                status: CleaningBookingStatus.awaitingCustomerCompletion,
              ),
              CleaningOrderModel(id: 3, status: 'AWAITING_CUSTOMER_COMPLETION'),
            ],
          );

      expect(ids, <int>[2, 3]);
    });
  });
}
