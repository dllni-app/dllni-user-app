import 'package:dllni_user_app/features/cl_main/view/widgets/cl_booking_review_overview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget review({
    required bool requested,
    List<int>? missing,
    List<String> names = const [],
  }) {
    return MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: SingleChildScrollView(
            child: ClBookingReviewOverview(
              service: 'تنظيف عادي',
              address: 'المنزل',
              workerLabel: '1',
              materialsRequested: requested,
              missingMaterialTypeIds: missing,
              missingMaterialNames: names,
              services: const [],
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('review shows client has all materials', (tester) async {
    await tester.pumpWidget(review(requested: false, missing: const []));
    expect(find.text('المواد متوفرة لدى العميل'), findsOneWidget);
    expect(find.textContaining('الفريق يوفر'), findsNothing);
  });

  testWidgets('review shows provider supplies everything', (tester) async {
    await tester.pumpWidget(review(requested: true));
    expect(find.text('الفريق يوفر جميع المواد المطلوبة'), findsOneWidget);
  });

  testWidgets('review names missing materials instead of claiming all', (
    tester,
  ) async {
    await tester.pumpWidget(
      review(
        requested: true,
        missing: const [10, 15],
        names: const ['منظف الأرض', 'معقم الأسطح'],
      ),
    );
    expect(
      find.text('الفريق يوفر الناقص: منظف الأرض، معقم الأسطح'),
      findsOneWidget,
    );
    expect(find.text('الفريق يوفر جميع المواد المطلوبة'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
