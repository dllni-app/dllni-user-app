import 'package:dllni_user_app/features/orders/data/models/merchant_order_status_label_ar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('canonical merchant statuses always have localized Arabic labels', () {
    const statuses = <String, String>{
      'pending': 'قيد الانتظار',
      'accepted': 'تم القبول',
      'preparing': 'قيد التحضير',
      'ready_for_pickup': 'جاهز للاستلام',
      'picked_up': 'تم الاستلام',
      'delivered': 'تم التوصيل',
      'completed': 'مكتمل',
      'cancelled': 'ملغي',
      'rejected': 'مرفوض',
    };
    for (final entry in statuses.entries) {
      expect(
        merchantOrderStatusLabelAr(entry.key, fallback: 'Ready For Pickup'),
        entry.value,
      );
    }
  });

  test('English API fallback does not leak into Arabic homepage', () {
    expect(
      merchantOrderStatusLabelAr(
        'Ready For Pickup',
        fallback: 'Ready For Pickup',
      ),
      'جاهز للاستلام',
    );
    expect(
      merchantOrderStatusLabelAr(
        'new_untranslated_state',
        fallback: 'In Progress',
      ),
      'قيد المعالجة',
    );
    expect(
      merchantOrderStatusLabelAr('unknown', fallback: 'جاري التوصيل'),
      'جاري التوصيل',
    );
  });
}
