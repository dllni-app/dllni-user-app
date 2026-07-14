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
        home: Scaffold(
          body: NotificationFeedItem(notification: notification),
        ),
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
        home: Scaffold(
          body: NotificationFeedItem(notification: notification),
        ),
      ),
    );

    expect(find.text('رسالة عادية'), findsOneWidget);
  });
}
