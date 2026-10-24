import 'package:flutter_test/flutter_test.dart';
import 'package:dllni_user_app/core/pricing/restaurant_discount_label.dart';
import 'package:dllni_user_app/features/rs_discover/view/models/store_product_item.dart';

void main() {
  test('direct markdown 25 to 10 shows 60 percent rather than losing 15 percent offer', () {
    final item = StoreProductItem(
      id: 1, name: 'QA', description: '', priceText: '', category: '',
      displayPriceValue: 10, oldPriceValue: 25,
      offerDiscountType: 'percentage', offerDiscountValue: 15,
      isOfferActive: true, offerBadgeText: '15%',
    );
    expect(item.displayedSavingsBadge, '60%');
    expect(item.offerIsEffective, isFalse);
    expect(item.applicableOfferTitle, isNull);
  });

  test('the advertised offer appears only when it wins', () {
    final item = StoreProductItem(
      name: 'QA', description: '', priceText: '', category: '',
      displayPriceValue: 85, oldPriceValue: 100,
      offerDiscountType: 'percentage', offerDiscountValue: 15,
      isOfferActive: true,
    );
    expect(item.displayedSavingsBadge, '15%');
    expect(item.offerIsEffective, isTrue);
  });

  test('rounding and boundaries', () {
    expect(RestaurantDiscountLabel.savingsBadge(25, 10), '60%');
    expect(RestaurantDiscountLabel.savingsBadge(0, 0), isNull);
    expect(RestaurantDiscountLabel.savingsBadge(10, 10), isNull);
    expect(RestaurantDiscountLabel.savingsBadge(100, 84.5), '15.5%');
  });
}
