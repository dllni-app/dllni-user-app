import 'package:dllni_user_app/features/cl_main/data/models/estimate_price_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses backend multi-day estimate schedule pricing', () {
    final result = estimatePriceResponseModelFromJson({
      'pricing': {
        'basePrice': 7200,
        'travelFee': 0,
        'adminMargin': 0,
        'totalPrice': 7200,
        'currency': 'SYP',
      },
      'schedule': {
        'mode': 'multi_day',
        'daysCount': 2,
        'totalHours': 9,
        'sessions': [
          {
            'sequence': 1,
            'date': '2026-09-01',
            'time': '16:00',
            'hours': 4,
            'basePrice': 3200,
            'travelFee': 0,
            'adminMargin': 0,
            'totalPrice': 3200,
          },
          {
            'sequence': 2,
            'date': '2026-09-03',
            'time': '17:00',
            'hours': 5,
            'basePrice': 4000,
            'travelFee': 0,
            'adminMargin': 0,
            'totalPrice': 4000,
          },
        ],
      },
    });

    expect(result.pricing?.totalPrice, 7200);
    expect(result.schedule?.mode, 'multi_day');
    expect(result.schedule?.daysCount, 2);
    expect(result.schedule?.totalHours, 9);
    expect(result.schedule?.sessions.length, 2);
    expect(result.schedule?.sessionAt(0)?.totalPrice, 3200);
    expect(result.schedule?.sessionAt(1)?.totalPrice, 4000);
  });
}
