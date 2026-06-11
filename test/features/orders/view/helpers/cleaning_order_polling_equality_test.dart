import 'package:dllni_user_app/features/orders/data/models/cleaning_orders_api_models.dart';
import 'package:dllni_user_app/features/orders/view/helpers/cleaning_order_polling_equality.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('cleaningOrderDetailDisplayEquals', () {
    CleaningOrderDetailModel baseOrder({bool? isPricingFinal}) {
      return CleaningOrderDetailModel(
        id: 1,
        bookingNumber: 'CL-1',
        status: 'pending',
        basePrice: 1000,
        travelFee: 0,
        totalPrice: 1000,
        isPricingFinal: isPricingFinal,
      );
    }

    test('returns true when pricing fields match', () {
      final a = baseOrder(isPricingFinal: false);
      final b = baseOrder(isPricingFinal: false);

      expect(cleaningOrderDetailDisplayEquals(a, b), isTrue);
    });

    test('returns false when isPricingFinal changes', () {
      final provisional = baseOrder(isPricingFinal: false);
      final finalized = baseOrder(isPricingFinal: true);

      expect(cleaningOrderDetailDisplayEquals(provisional, finalized), isFalse);
    });

    test('returns true when isPricingFinal is finalized on both sides', () {
      final a = baseOrder(isPricingFinal: true);
      final b = baseOrder(isPricingFinal: true);

      expect(cleaningOrderDetailDisplayEquals(a, b), isTrue);
    });
  });
}
