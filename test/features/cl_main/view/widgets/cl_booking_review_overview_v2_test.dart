import 'package:dllni_user_app/features/cl_main/view/widgets/cl_booking_review_overview.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_room_size_breakdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('custom room types appear in the review with captured labels', (
    tester,
  ) async {
    await _pumpReview(
      tester,
      breakdown: const CleaningRoomSizeBreakdown(
        extra: <String, CleaningRoomSizeBucket>{
          'toilet': CleaningRoomSizeBucket(small: 2),
        },
      ),
      roomNamesByCode: const <String, String>{'toilet': 'مرحاض'},
    );

    expect(find.text('2 غرف ومساحات'), findsOneWidget);
    expect(find.text('مرحاض: 2'), findsOneWidget);
    expect(find.text('toilet: 2'), findsNothing);
  });

  testWidgets('mixed legacy, custom, and balcony rows total each unit once', (
    tester,
  ) async {
    await _pumpReview(
      tester,
      breakdown: const CleaningRoomSizeBreakdown(
        bedroom: CleaningRoomSizeBucket(small: 1),
        balcony: CleaningRoomSizeBucket(medium: 2),
        extra: <String, CleaningRoomSizeBucket>{
          'toilet': CleaningRoomSizeBucket(large: 1),
          'empty_room': CleaningRoomSizeBucket(),
        },
      ),
      roomNamesByCode: const <String, String>{'toilet': '   '},
    );

    expect(find.text('4 غرف ومساحات'), findsOneWidget);
    expect(find.text('غرف النوم: 1'), findsOneWidget);
    expect(find.text('الشرفات: 2'), findsOneWidget);
    expect(find.text('toilet: 1'), findsOneWidget);
    expect(find.text('empty room: 0'), findsNothing);
    expect(find.text('empty_room: 0'), findsNothing);
    expect(find.textContaining(': '), findsNWidgets(3));
  });

  testWidgets('zero and empty breakdowns do not fabricate room summary', (
    tester,
  ) async {
    await _pumpReview(
      tester,
      breakdown: const CleaningRoomSizeBreakdown(
        extra: <String, CleaningRoomSizeBucket>{
          'toilet': CleaningRoomSizeBucket(),
        },
      ),
    );

    expect(find.text('0 غرف ومساحات'), findsNothing);
    expect(find.textContaining('غرف النوم:'), findsNothing);
    expect(find.textContaining('toilet:'), findsNothing);
  });

  testWidgets('mixed per-room cleaning shows both modes in booking review', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ClBookingReviewOverview(
              service: 'حوسة',
              address: 'عنوان تجريبي',
              workerLabel: '3',
              materialsRequested: false,
              services: <String>[],
              roomCleaningModes: <String, String>{
                'bedroom.medium.1': 'deep',
                'bedroom.medium.2': 'regular',
                'kitchen.medium.1': 'regular',
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('حوسة وتعزيل'), findsOneWidget);
    expect(find.text('تعزيل: 1 · حوسة: 2'), findsOneWidget);
  });
}

Future<void> _pumpReview(
  WidgetTester tester, {
  required CleaningRoomSizeBreakdown breakdown,
  Map<String, String> roomNamesByCode = const <String, String>{},
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: ClBookingReviewOverview(
            service: 'تنظيف',
            address: 'عنوان تجريبي',
            workerLabel: '2',
            materialsRequested: false,
            services: const <String>[],
            roomSizeBreakdown: breakdown,
            roomNamesByCode: roomNamesByCode,
          ),
        ),
      ),
    ),
  );
}
