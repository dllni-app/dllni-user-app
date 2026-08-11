import 'package:dllni_user_app/features/rs_discover/view/models/store_product_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  StoreProductItem product({
    num? displayPrice = 10,
    num? oldPrice,
    String discountType = 'percentage',
    num discountValue = 15,
    bool isOfferActive = true,
  }) {
    return StoreProductItem(
      name: 'Test product',
      description: '',
      priceText: '',
      category: '',
      displayPriceValue: displayPrice,
      oldPriceValue: oldPrice,
      offerDiscountType: discountType,
      offerDiscountValue: discountValue,
      isOfferActive: isOfferActive,
    );
  }

  group('StoreProductItem offer pricing', () {
    test('applies percentage offer to the displayed price', () {
      final item = product();

      expect(item.resolvedDisplayPriceValue, closeTo(8.5, 0.0001));
      expect(item.resolvedOldPriceValue, 10);
    });

    test('applies fixed amount offer to the displayed price', () {
      final item = product(
        discountType: 'fixed_amount',
        discountValue: 3,
      );

      expect(item.resolvedDisplayPriceValue, 7);
      expect(item.resolvedOldPriceValue, 10);
    });

    test('does not stack offer discount over a server discount', () {
      final item = product(displayPrice: 8, oldPrice: 10);

      expect(item.resolvedDisplayPriceValue, 8);
      expect(item.resolvedOldPriceValue, 10);
    });

    test('ignores inactive offers', () {
      final item = product(isOfferActive: false);

      expect(item.resolvedDisplayPriceValue, 10);
      expect(item.resolvedOldPriceValue, isNull);
    });

    test('caps percentage discounts and never returns a negative price', () {
      final item = product(discountValue: 150);

      expect(item.resolvedDisplayPriceValue, 0);
      expect(item.resolvedOldPriceValue, 10);
    });
  });
}
