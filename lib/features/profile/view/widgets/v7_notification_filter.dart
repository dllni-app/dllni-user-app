import '../../data/models/fetch_notifications_model.dart';

/// Client-side presentation filtering. Does not change backend notification state.
bool notificationMatchesV7Filter(
  FetchNotificationsModelDataItem item,
  String filter,
) {
  switch (filter) {
    case 'unread':
      return item.isRead != true;
    case 'orders':
      final type = item.type.toLowerCase();
      final category = (item.category ?? '').toLowerCase();
      return category == 'orders' ||
          type.contains('booking') ||
          type.contains('order');
    case 'offers':
      final type = item.type.toLowerCase();
      final category = (item.category ?? '').toLowerCase();
      return category == 'offers' || type.contains('offer');
    default:
      return true;
  }
}
