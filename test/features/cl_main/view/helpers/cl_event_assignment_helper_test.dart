import 'package:dllni_user_app/features/cl_main/data/models/estimate_price_response_model.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_assignment_mode.dart';
import 'package:dllni_user_app/features/cl_main/view/helpers/cl_event_assignment_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveEventAssignmentFields', () {
    test('uses preferred worker mode when worker selected', () {
      final fields = resolveEventAssignmentFields(
        selectedWorkerId: 77,
        suggestedTeamSize: 3,
      );

      expect(fields.assignmentMode, CleaningAssignmentMode.preferredWorker);
      expect(fields.numberOfWorkers, 1);
      expect(fields.preferredWorkerId, 77);
    });

    test('uses open count with suggested team size when no worker selected', () {
      final fields = resolveEventAssignmentFields(
        selectedWorkerId: null,
        suggestedTeamSize: 3,
        workerAcceptance: const EstimateWorkerAcceptanceModel(required: 2),
      );

      expect(fields.assignmentMode, CleaningAssignmentMode.openCount);
      expect(fields.numberOfWorkers, 3);
      expect(fields.preferredWorkerId, isNull);
    });

    test('falls back to workerAcceptance.required for team size', () {
      final fields = resolveEventAssignmentFields(
        selectedWorkerId: null,
        suggestedTeamSize: null,
        workerAcceptance: const EstimateWorkerAcceptanceModel(required: 4),
      );

      expect(fields.numberOfWorkers, 4);
    });
  });

  group('resolveSuggestedTeamSize', () {
    test('prefers recommendation then workerAcceptance', () {
      const estimate = EstimatePriceResponseModel(
        recommendation: EstimateRecommendationModel(suggestedTeamSize: 5),
        workerAcceptance: EstimateWorkerAcceptanceModel(required: 2),
      );

      expect(resolveSuggestedTeamSize(estimate), 5);
    });
  });
}
