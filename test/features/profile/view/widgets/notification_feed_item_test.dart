import 'package:dllni_user_app/features/profile/data/models/fetch_notifications_model.dart';
import 'package:dllni_user_app/features/profile/view/widgets/notification_feed_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the worker response for a rejected time extension', (
    tester,
  ) async {
    const response = 'لا أستطيع تمديد وقت الخدمة اليوم.';
    const notification = FetchNotificationsModelDataItem(
      type: 'time_extension_rejected',
      canonicalType: 'cleaning.booking.time_extension_rejected',
      title: 'تم رفض تمديد الوقت',
      body: 'تم رفض تمديد الوقت للحجز.',
      data: <String, dynamic>{'workerRejectMessage': response},
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: NotificationFeedItem(notification: notification)),
      ),
    );

    expect(find.text('رد العامل: $response'), findsOneWidget);
    expect(find.text(notification.body!), findsNothing);
  });

  testWidgets('keeps the normal body for other notifications', (tester) async {
    const notification = FetchNotificationsModelDataItem(
      type: 'system',
      title: 'تنبيه',
      body: 'رسالة عادية',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: NotificationFeedItem(notification: notification)),
      ),
    );

    expect(find.text('رسالة عادية'), findsOneWidget);
  });

  testWidgets('shows preferred-worker rejected cleaning notification body', (
    tester,
  ) async {
    const body =
        'رفض العامل المخصص الطلب، وتم تحويله إلى طلب عام. نبحث الآن عن عامل بديل.';
    const notification = FetchNotificationsModelDataItem(
      type: 'preferred_worker_rejected',
      canonicalType: 'cleaning.booking.preferred_worker_rejected',
      title: 'رفض العامل المخصص الطلب',
      body: body,
      module: 'cleaning',
      data: <String, dynamic>{
        'bookingId': 45,
        'status': 'pending',
        'assignmentMode': 'open_count',
        'convertedToOpen': true,
      },
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: NotificationFeedItem(notification: notification)),
      ),
    );

    expect(find.text(body), findsOneWidget);
  });
}
