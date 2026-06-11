import 'package:common_package/common_package.dart';
import 'package:dartz/dartz.dart';
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

    test(
      'findAwaitingVerificationOrderIds ignores awaiting worker start confirmation',
      () {
        final ids =
            CleaningGlobalVerificationGateCoordinator.findAwaitingVerificationOrderIds(
              <CleaningOrderModel>[
                CleaningOrderModel(
                  id: 10,
                  status: CleaningBookingStatus.awaitingWorkerStartConfirmation,
                ),
                CleaningOrderModel(
                  id: 11,
                  status: CleaningBookingStatus.awaitingStartVerification,
                ),
              ],
            );

        expect(ids, <int>[11]);
      },
    );

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

    test(
      'switches to unfiltered polling when filtered status request is 422',
      () {
        final response = Left<Failure, FetchCleaningOrdersModel>(
          const ServerFailure(
            message: 'The selected filter.status is invalid.',
            statusCode: 422,
          ),
        );

        final shouldFallback =
            CleaningGlobalVerificationGateCoordinator.shouldSwitchToUnfilteredPolling(
              requestedStatus: CleaningBookingStatus.awaitingStartVerification,
              response: response,
            );

        expect(shouldFallback, isTrue);
      },
    );

    test(
      'does not switch to unfiltered polling when request is already unfiltered',
      () {
        final response = Left<Failure, FetchCleaningOrdersModel>(
          const ServerFailure(
            message: 'The selected filter.status is invalid.',
            statusCode: 422,
          ),
        );

        final shouldFallback =
            CleaningGlobalVerificationGateCoordinator.shouldSwitchToUnfilteredPolling(
              requestedStatus: null,
              response: response,
            );

        expect(shouldFallback, isFalse);
      },
    );

    test('resolves gate targets from unfiltered lifecycle list', () {
      final targets =
          CleaningGlobalVerificationGateCoordinator.resolvePolledGateTargets(<
            CleaningOrderModel
          >[
            CleaningOrderModel(id: 1, status: CleaningBookingStatus.pending),
            CleaningOrderModel(
              id: 2,
              status: CleaningBookingStatus.awaitingStartVerification,
            ),
            CleaningOrderModel(
              id: 3,
              status: CleaningBookingStatus.awaitingCustomerCompletion,
            ),
            CleaningOrderModel(id: 4, status: CleaningBookingStatus.completed),
          ]);

      expect(targets.awaitingVerificationOrderIds, <int>[2]);
      expect(targets.awaitingCompletionOrderIds, <int>[3]);
    });

    test('preserves API response order for awaiting verification queue', () {
      final targets =
          CleaningGlobalVerificationGateCoordinator.resolvePolledGateTargets(
            <CleaningOrderModel>[
              CleaningOrderModel(
                id: 50,
                status: CleaningBookingStatus.awaitingStartVerification,
              ),
              CleaningOrderModel(id: 11, status: CleaningBookingStatus.pending),
              CleaningOrderModel(
                id: 37,
                status: CleaningBookingStatus.awaitingStartVerification,
              ),
              CleaningOrderModel(
                id: 15,
                status: CleaningBookingStatus.awaitingCustomerCompletion,
              ),
              CleaningOrderModel(
                id: 29,
                status: CleaningBookingStatus.awaitingStartVerification,
              ),
            ],
          );

      expect(targets.awaitingVerificationOrderIds, <int>[50, 37, 29]);
      expect(targets.awaitingCompletionOrderIds, <int>[15]);
    });

    test(
      'completion poll + awaiting_start_verification -> completion then start dialog',
      () {
        final decision =
            CleaningGlobalVerificationGateCoordinator.resolveCompletionGateHandlingDecision(
              requestedFromCompletionPoll: true,
              normalizedDetailsStatus:
                  CleaningBookingStatus.awaitingStartVerification,
            );

        expect(
          decision,
          CompletionGateHandlingDecision.completionThenStartDialog,
        );
      },
    );

    test('awaiting_customer_completion -> completion only', () {
      final decision =
          CleaningGlobalVerificationGateCoordinator.resolveCompletionGateHandlingDecision(
            requestedFromCompletionPoll: true,
            normalizedDetailsStatus:
                CleaningBookingStatus.awaitingCustomerCompletion,
          );

      expect(decision, CompletionGateHandlingDecision.completionOnly);
    });

    test(
      'non completion context + awaiting_start_verification -> no completion sheet',
      () {
        final decision =
            CleaningGlobalVerificationGateCoordinator.resolveCompletionGateHandlingDecision(
              requestedFromCompletionPoll: false,
              normalizedDetailsStatus:
                  CleaningBookingStatus.awaitingStartVerification,
            );

        expect(decision, CompletionGateHandlingDecision.noCompletionSheet);
      },
    );

    test('poll priority resolves completion before verification', () {
      final priority =
          CleaningGlobalVerificationGateCoordinator.resolveStatusPollPriority();

      expect(priority, <String>[
        CleaningBookingStatus.awaitingCustomerCompletion,
        CleaningBookingStatus.awaitingStartVerification,
      ]);
    });

    test(
      'unfiltered prompt priority resolves completion before verification',
      () {
        final priority =
            CleaningGlobalVerificationGateCoordinator.resolvePolledPromptPriority();

        expect(priority, <CleaningPolledPromptPriority>[
          CleaningPolledPromptPriority.completion,
          CleaningPolledPromptPriority.startVerification,
        ]);
      },
    );
  });
}
