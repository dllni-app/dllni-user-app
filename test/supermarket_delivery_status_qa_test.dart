import 'package:flutter_test/flutter_test.dart';
import 'package:dllni_user_app/features/orders/data/models/delivery_status_label_ar.dart';

void main() {
  test('delivery and supermarket status codes never leak in English', () {
    expect(deliveryStatusLabelAr('ready_for_pickup'), 'الطلب جاهز للاستلام');
    expect(deliveryStatusLabelAr('stopped'), 'توقف البحث عن مندوب');
    expect(deliveryStatusLabelAr('accepted'), 'تم قبول التوصيل');
    expect(
      deliveryStatusLabelAr('mystery', fallback: 'Ready For Pickup'),
      'جاري تحديث حالة التوصيل',
    );
    expect(
      deliveryStatusLabelAr('unknown', fallback: 'تم الاستلام'),
      'تم الاستلام',
    );
  });
}
