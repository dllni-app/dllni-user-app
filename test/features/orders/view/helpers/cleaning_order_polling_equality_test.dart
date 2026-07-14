import 'package:dllni_user_app/features/orders/data/models/cleaning_orders_api_models.dart';
import 'package:dllni_user_app/features/orders/view/helpers/cleaning_order_polling_equality.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('cleaningOrderDetailDisplayEquals', () {
    CleaningOrderDetailModel baseOrder({
      bool? isPricingFinal,
      List<CleaningWorkerAssignmentModel>? workerAssignments,
    }) {
      return CleaningOrderDetailModel(
        id: 1,
        bookingNumber: 'CL-1',
        status: 'pending',
        basePrice: 1000,
        travelFee: 0,
        totalPrice: 1000,
        isPricingFinal: isPricingFinal,
        workerAssignments: workerAssignments,
      );
    }

    test('returns true when pricing fields match', () {
      final a = baseOrder(isPricingFinal: false);
      final b = baseOrder(isPricingFinal: false);

      expect(cleaningOrderDetailDisplayEquals(a, b), isTrue);
    });

    test('returns false when isPricingFinal changes', () {
      final provisional = baseOrder(isPricingFinal: false);
      final finalized = baseOrder(isPricingFinal: true);

      expect(cleaningOrderDetailDisplayEquals(provisional, finalized), isFalse);
    });

    test('returns true when isPricingFinal is finalized on both sides', () {
      final a = baseOrder(isPricingFinal: true);
      final b = baseOrder(isPricingFinal: true);

      expect(cleaningOrderDetailDisplayEquals(a, b), isTrue);
    });

    test('returns false when an existing worker assignment status changes', () {
      final travelling = baseOrder(
        workerAssignments: <CleaningWorkerAssignmentModel>[
          CleaningWorkerAssignmentModel(
            id: 11,
            workerId: 7,
            status: 'accepted_waiting_for_order_start',
          ),
        ],
      );
      final arrived = baseOrder(
        workerAssignments: <CleaningWorkerAssignmentModel>[
          CleaningWorkerAssignmentModel(
            id: 11,
            workerId: 7,
            status: 'awaiting_start_verification',
          ),
        ],
      );

      expect(cleaningOrderDetailDisplayEquals(travelling, arrived), isFalse);
    });

    test('returns false when worker assignment content changes at same length', () {
      final before = baseOrder(
        workerAssignments: <CleaningWorkerAssignmentModel>[
          CleaningWorkerAssignmentModel(
            id: 11,
            workerId: 7,
            status: 'accepted_waiting_for_order_start',
            roomCount: 1,
          ),
          CleaningWorkerAssignmentModel(
            id: 12,
            workerId: 8,
            status: 'accepted_waiting_for_order_start',
            roomCount: 1,
          ),
        ],
      );
      final after = baseOrder(
        workerAssignments: <CleaningWorkerAssignmentModel>[
          CleaningWorkerAssignmentModel(
            id: 11,
            workerId: 7,
            status: 'accepted_waiting_for_order_start',
            roomCount: 2,
          ),
          CleaningWorkerAssignmentModel(
            id: 12,
            workerId: 8,
            status: 'accepted_waiting_for_order_start',
            roomCount: 1,
          ),
        ],
      );

      expect(cleaningOrderDetailDisplayEquals(before, after), isFalse);
    });
  });
}
