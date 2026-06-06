import 'package:dllni_user_app/features/cl_main/data/models/estimate_price_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('EstimatePriceResponseModel parses workerRoomAssignments', () {
    final model = EstimatePriceResponseModel.fromJson({
      'pricing': {
        'totalPrice': 12000,
      },
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
}
