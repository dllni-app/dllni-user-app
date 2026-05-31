import 'package:dllni_user_app/features/cl_main/data/models/estimate_price_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EstimatePricingModel parsing', () {
    test(
      'parses distance, admin margin, and pricing final flag (snake_case)',
      () {
        final model = estimatePriceResponseModelFromJson(<String, dynamic>{
          'pricing': <String, dynamic>{
            'base_price': 1000,
            'travel_fee': 200,
            'addons_total': 100,
            'total_price': 1350,
            'distance_km': '4.125',
            'admin_margin': 50,
            'is_pricing_final': false,
            'currency': 'SYP',
          },
        });

        final pricing = model.pricing;
        expect(pricing, isNotNull);
        expect(pricing!.distanceKm, 4.125);
        expect(pricing.adminMargin, 50);
        expect(pricing.isPricingFinal, isFalse);
      },
    );

    test('parses camelCase keys and numeric bool for pricing final', () {
      final model = estimatePriceResponseModelFromJson(<String, dynamic>{
        'pricing': <String, dynamic>{
          'distanceKm': 3.5,
          'adminMargin': '12.75',
          'isPricingFinal': 1,
        },
      });

      final pricing = model.pricing;
      expect(pricing, isNotNull);
      expect(pricing!.distanceKm, 3.5);
      expect(pricing.adminMargin, 12.75);
      expect(pricing.isPricingFinal, isTrue);
    });
  });
}
