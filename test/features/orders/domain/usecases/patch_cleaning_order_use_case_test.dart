import 'package:dllni_user_app/features/orders/domain/usecases/patch_cleaning_order_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('getBody preserves a schedule-only partial PATCH payload', () {
    final params = PatchCleaningOrderParams(
      cleaningOrderId: 42,
      changes: const {
        'scheduledDate': '2026-08-25',
        'scheduledTime': '11:30',
      },
    );

    expect(params.cleaningOrderId, 42);
    expect(params.getBody(), {
      'scheduledDate': '2026-08-25',
      'scheduledTime': '11:30',
    });
    expect(params.getBody().containsKey('propertyType'), isFalse);
    expect(params.getBody().containsKey('basePrice'), isFalse);
    expect(params.getBody().containsKey('totalPrice'), isFalse);
  });

  test('getBody sends only explicitly supplied configuration changes', () {
    final params = PatchCleaningOrderParams(
      cleaningOrderId: 9,
      changes: const {
        'propertyDetails': {
          'address': 'Aleppo - Al Furqan',
          'location_name': 'المنزل',
        },
        'addressLatitude': 36.2,
        'addressLongitude': 37.1,
      },
    );

    expect(params.getBody(), {
      'propertyDetails': {
        'address': 'Aleppo - Al Furqan',
        'location_name': 'المنزل',
      },
      'addressLatitude': 36.2,
      'addressLongitude': 37.1,
    });
    expect(params.getBody().containsKey('genderPreference'), isFalse);
    expect(params.getBody().containsKey('estimatedHours'), isFalse);
  });
}
