import 'package:dllni_user_app/features/cl_main/data/models/previous_workers_response_model.dart';
import 'package:dllni_user_app/features/cl_main/view/data/cl_worker_profile_route_args.dart';
import 'package:dllni_user_app/features/cl_main/view/screens/cl_worker_reviews_all_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows only server-backed aggregate worker rating data', (
    WidgetTester tester,
  ) async {
    const worker = PreviousWorkerModel(
      id: 42,
      name: 'مقدم خدمة تجريبي',
      rating: 4.8,
      ratings: PreviousWorkerRatingsModel(average: 4.8, count: 12),
    );
    const args = WorkerProfileRouteArgs(workerId: '42', worker: worker);

    await tester.pumpWidget(
      const MaterialApp(home: ClWorkerReviewsAllScreen(args: args)),
    );

    expect(find.text('مقدم خدمة تجريبي'), findsOneWidget);
    expect(find.text('4.8'), findsOneWidget);
    expect(find.text('12 تقييم'), findsOneWidget);
    expect(find.text('تفاصيل المراجعات غير متاحة حالياً'), findsOneWidget);
    expect(find.text('أحمد محمد'), findsNothing);
  });
}
