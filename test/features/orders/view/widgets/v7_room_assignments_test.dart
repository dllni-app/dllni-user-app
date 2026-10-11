import 'package:dllni_user_app/features/orders/data/models/cleaning_orders_api_models.dart';
import 'package:dllni_user_app/features/orders/view/widgets/cleaning_room_assignments_section_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('rooms shown read-only when the server disallows editing', (
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
                assignedWorkerId: 13,
              ),
            ],
            acceptedWorkers: [CleaningWorkerAssignmentModel(workerId: 13)],
            isEditable: false,
            isSaving: false,
            onAssignRoom: (_, _) {},
          ),
        ),
      ),
    );
    expect(find.text('المطبخ'), findsOneWidget);
    expect(find.byType(PopupMenuButton<int>), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('editable room forwards selected worker to callback', (
    tester,
  ) async {
    int? selectedRoom;
    int? selectedWorker;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CleaningRoomAssignmentsSectionWidget(
            roomAssignments: [
              CleaningRoomAssignmentModel(
                id: 5,
                displayLabel: 'المطبخ',
                assignedWorkerId: null,
              ),
            ],
            acceptedWorkers: [CleaningWorkerAssignmentModel(workerId: 13)],
            isEditable: true,
            isSaving: false,
            onAssignRoom: (room, worker) {
              selectedRoom = room;
              selectedWorker = worker;
            },
          ),
        ),
      ),
    );
    await tester.tap(find.byTooltip('تحديد العامل'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('العامل #13').last);
    await tester.pumpAndSettle();
    expect(selectedRoom, 5);
    expect(selectedWorker, 13);
    expect(tester.takeException(), isNull);
  });
}
