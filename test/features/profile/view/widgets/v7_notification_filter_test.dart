import 'package:dllni_user_app/features/profile/data/models/fetch_notifications_model.dart';
import 'package:dllni_user_app/features/profile/view/widgets/v7_notification_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const booking = FetchNotificationsModelDataItem(
    type: 'cleaning.booking.worker_assigned',
    isRead: false,
  );
  const offer = FetchNotificationsModelDataItem(
    type: 'new_offer',
    category: 'offers',
    isRead: true,
  );
  const system = FetchNotificationsModelDataItem(
    type: 'system_alert',
    category: 'system',
    isRead: true,
  );

  test('all category does not hide any notification', () {
    expect(notificationMatchesV7Filter(booking, 'all'), isTrue);
    expect(notificationMatchesV7Filter(offer, 'all'), isTrue);
    expect(notificationMatchesV7Filter(system, 'all'), isTrue);
  });
  test('unread category uses backend isRead', () {
    expect(notificationMatchesV7Filter(booking, 'unread'), isTrue);
    expect(notificationMatchesV7Filter(offer, 'unread'), isFalse);
  });
  test('orders and offers filters use canonical order type fallback', () {
    expect(notificationMatchesV7Filter(booking, 'orders'), isTrue);
    expect(notificationMatchesV7Filter(booking, 'offers'), isFalse);
    expect(notificationMatchesV7Filter(offer, 'offers'), isTrue);
    expect(notificationMatchesV7Filter(offer, 'orders'), isFalse);
    expect(notificationMatchesV7Filter(system, 'orders'), isFalse);
  });
}
