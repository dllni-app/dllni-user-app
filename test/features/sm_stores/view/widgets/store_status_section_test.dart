import 'package:dllni_user_app/features/sm_stores/data/models/get_supermarket_store_details_model.dart';
import 'package:dllni_user_app/features/sm_stores/view/widgets/store_status_section.dart';
import 'package:flutter_test/flutter_test.dart';

SupermarketStoreDetailsHour _hour({
  required String day,
  required String open,
  required String close,
  bool isClosed = false,
}) {
  return SupermarketStoreDetailsHour(
    dayOfWeek: day,
    openTime: open,
    closeTime: close,
    isClosed: isClosed,
  );
}

void main() {
  group('supermarketStoreIsOpenNow', () {
    test('returns null when the API has no store hours', () {
      expect(
        supermarketStoreIsOpenNow(
          const [],
          now: DateTime(2026, 8, 11, 12),
        ),
        isNull,
      );
    });

    test('returns true during the current API opening interval', () {
      expect(
        supermarketStoreIsOpenNow(
          [
            _hour(
              day: 'tuesday',
              open: '08:00:00',
              close: '22:00:00',
            ),
          ],
          now: DateTime(2026, 8, 11, 12),
        ),
        isTrue,
      );
    });

    test('returns false outside the current API opening interval', () {
      expect(
        supermarketStoreIsOpenNow(
          [
            _hour(
              day: 'tuesday',
              open: '08:00:00',
              close: '22:00:00',
            ),
          ],
          now: DateTime(2026, 8, 11, 23),
        ),
        isFalse,
      );
    });

    test('respects a closed day returned by the API', () {
      expect(
        supermarketStoreIsOpenNow(
          [
            _hour(
              day: 'tuesday',
              open: '08:00:00',
              close: '22:00:00',
              isClosed: true,
            ),
          ],
          now: DateTime(2026, 8, 11, 12),
        ),
        isFalse,
      );
    });

    test('supports API opening intervals that cross midnight', () {
      expect(
        supermarketStoreIsOpenNow(
          [
            _hour(
              day: 'monday',
              open: '18:00:00',
              close: '02:00:00',
            ),
          ],
          now: DateTime(2026, 8, 11, 1),
        ),
        isTrue,
      );
    });
  });
}
