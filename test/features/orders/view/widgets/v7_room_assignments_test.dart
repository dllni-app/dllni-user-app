import 'package:dllni_user_app/features/orders/data/models/cleaning_orders_api_models.dart';
import 'package:dllni_user_app/features/orders/view/widgets/cleaning_room_assignments_section_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'customer model reads shared booking roomTasks instead of assignments',
    () {
      final order = CleaningOrderDetailModel.fromJson({
        'id': 40,
        'roomTasks': [
          {'id': 5, 'roomKey': 'kitchen.medium.1', 'displayLabel': 'المطبخ'},
          {'id': 6, 'roomKey': 'bedroom.small.1', 'displayLabel': 'غرفة نوم'},
        ],
      });
      expect(order.roomAssignments, hasLength(2));
      expect(order.roomAssignments!.first.displayLabel, 'المطبخ');
    },
  );

  testWidgets('shows all requested rooms without worker ownership or editing', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CleaningRoomAssignmentsSectionWidget(
            roomAssignments: [
              CleaningRoomAssignmentModel(
                id: 5,
                displayLabel: 'المطبخ',
                assignedWorkerId:
                    13, // historical payload cannot re-enable editing
              ),
              CleaningRoomAssignmentModel(id: 6, displayLabel: 'غرفة نوم'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('المطبخ'), findsOneWidget);
    expect(find.text('غرفة نوم'), findsOneWidget);
    expect(find.text('الغرف المطلوبة'), findsOneWidget);
    expect(find.byType(PopupMenuButton<int>), findsNothing);
    expect(find.textContaining('العامل #13'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
