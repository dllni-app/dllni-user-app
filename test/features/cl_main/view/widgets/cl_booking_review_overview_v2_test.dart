import 'package:dllni_user_app/features/cl_main/view/widgets/cl_booking_review_overview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
