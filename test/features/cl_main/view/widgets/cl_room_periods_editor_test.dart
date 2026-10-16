import 'package:dllni_user_app/core/models/cleaning_service_extras.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_progressive_room_state.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_room_period_draft.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_room_size_breakdown.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/cl_room_periods_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final day = DateTime(2026, 11, 4);
  final rooms = const CleaningProgressiveRoomState()
      .setCount(CleaningRoomType.bedroom, 2)
      .units;

  testWidgets('materials stay local until customer confirms copy to all', (
    tester,
  ) async {
    var draft = CleaningRoomPeriodDrafts.fromRooms(rooms, date: day);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => SingleChildScrollView(
              child: ClRoomPeriodsEditor(
                drafts: draft,
                phase: ClPeriodEditingPhase.materials,
                materials: const [
                  CleaningMaterialLineModel(
                    materialTypeId: 7,
                    name: 'منظف أرضيات',
                  ),
                ],
                onChanged: (next) => setState(() => draft = next),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('غرفة نوم 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('منظف أرضيات'));
    await tester.pumpAndSettle();
    expect(draft.periods.first.materialTypeIds, [7]);
    expect(draft.periods.last.materialTypeIds, isEmpty);

    await tester.tap(find.text('تطبيق هذه الاختيارات على بقية الفترات').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('هذه الفترة فقط'));
    await tester.pumpAndSettle();
    expect(draft.periods.last.materialTypeIds, isEmpty);

    await tester.tap(find.text('تطبيق هذه الاختيارات على بقية الفترات').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('تطبيق على كل الفترات'));
    await tester.pumpAndSettle();
    expect(draft.periods.last.materialTypeIds, [7]);
  });

  testWidgets('worker count immediately changes the visible room duration', (
    tester,
  ) async {
    var draft = CleaningRoomPeriodDrafts.fromRooms(rooms, date: day);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => SingleChildScrollView(
              child: ClRoomPeriodsEditor(
                drafts: draft,
                phase: ClPeriodEditingPhase.schedule,
                workMinutesByRoom: const {'bedroom.1': 180, 'bedroom.2': 120},
                onChanged: (next) => setState(() => draft = next),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('غرفة نوم 1'));
    await tester.pumpAndSettle();
    expect(find.textContaining('المدة المتوقعة: 180 دقيقة'), findsOneWidget);
    final add = find.descendant(
      of: find.byKey(const ValueKey('room_period_bedroom.1_schedule')),
      matching: find.byIcon(Icons.add_circle_outline),
    );
    await tester.tap(add);
    await tester.pumpAndSettle();
    expect(draft.periods.first.workers, 2);
    expect(draft.periods.last.workers, 1);
    expect(find.textContaining('المدة المتوقعة: 90 دقيقة'), findsOneWidget);
  });
}
