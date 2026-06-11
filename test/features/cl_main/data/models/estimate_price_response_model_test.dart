import 'package:dllni_user_app/features/cl_main/data/models/estimate_price_response_model.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_assignment_mode.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'EstimatePriceResponseModel parses workerAcceptance and assignmentMode',
    () {
      final model = EstimatePriceResponseModel.fromJson({
        'assignmentMode': 'open_count',
        'workerAcceptance': {
          'required': 3,
          'accepted': 0,
          'remaining': 3,
          'isFulfilled': false,
        },
      });

      expect(model.assignmentMode, CleaningAssignmentMode.openCount);
      expect(model.workerAcceptance?.required, 3);
      expect(model.workerAcceptance?.accepted, 0);
      expect(model.workerAcceptance?.remaining, 3);
      expect(model.workerAcceptance?.isFulfilled, isFalse);
      expect(model.suggestedTeamSize, 3);
    },
  );

  test('EstimatePriceResponseModel parses workerRoomAssignments', () {
    final model = EstimatePriceResponseModel.fromJson({
      'pricing': {'totalPrice': 12000},
      'workerRoomAssignments': [
        {
          'workerSlot': 1,
          'preferredWorkerId': null,
          'roomsWeight': 1.8,
          'estimatedServiceShareAmount': 4200,
          'rooms': [
            {
              'roomKey': 'bedroom.small.1',
              'roomType': 'bedroom',
              'roomSize': 'small',
            },
          ],
        },
      ],
    });

    expect(model.workerRoomAssignments, hasLength(1));
    expect(model.workerRoomAssignments.first.workerSlot, 1);
    expect(model.workerRoomAssignments.first.roomsWeight, 1.8);
    expect(model.workerRoomAssignments.first.estimatedServiceShareAmount, 4200);
  });

  test('EstimatePriceResponseModel parses event assistance pricing fields', () {
    final model = EstimatePriceResponseModel.fromJson({
      'pricing': {
        'basePrice': 8000,
        'totalPrice': 9000,
        'eventHourlyRate': 2500,
        'eventHours': 4,
        'serviceLines': <Map<String, dynamic>>[],
      },
      'recommendation': {
        'eventType': 'family_dinner',
        'guestCount': 20,
        'venueType': 'apartment',
        'customService': 'مساعدة يدوية في تجهيز الضيافة',
        'hours': 4,
        'suggestedTeamSize': 2,
      },
    });

    expect(model.pricing?.eventHourlyRate, 2500);
    expect(model.pricing?.eventHours, 4);
    expect(model.pricing?.serviceLines, isEmpty);
    expect(
      model.recommendation?.customService,
      'مساعدة يدوية في تجهيز الضيافة',
    );
    expect(model.recommendation?.hours, 4);
    expect(model.recommendation?.suggestedTeamSize, 2);
  });
}
