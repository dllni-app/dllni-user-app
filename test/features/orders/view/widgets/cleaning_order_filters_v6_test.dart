import 'package:flutter_test/flutter_test.dart';
import 'package:dllni_user_app/features/orders/view/widgets/orders_list_body.dart';
import 'package:dllni_user_app/features/orders/data/models/cleaning_booking_status.dart';

void main() {
  test('V6 cleaning filters preserve exact lifecycle groupings', () {
    expect(
      cleaningOrderMatchesFilter(
        CleaningBookingStatus.completed,
        CleaningOrdersListFilter.all,
      ),
      isTrue,
    );
    expect(
      cleaningOrderMatchesFilter(
        CleaningBookingStatus.cancelled,
        CleaningOrdersListFilter.active,
      ),
      isFalse,
    );
    expect(
      cleaningOrderMatchesFilter(
        CleaningBookingStatus.completed,
        CleaningOrdersListFilter.active,
      ),
      isFalse,
    );
    expect(
      cleaningOrderMatchesFilter(
        CleaningBookingStatus.inProgress,
        CleaningOrdersListFilter.active,
      ),
      isTrue,
    );
    expect(
      cleaningOrderMatchesFilter(
        CleaningBookingStatus.completed,
        CleaningOrdersListFilter.completed,
      ),
      isTrue,
    );
    expect(
      cleaningOrderMatchesFilter(
        CleaningBookingStatus.cancelled,
        CleaningOrdersListFilter.cancelled,
      ),
      isTrue,
    );
    expect(
      cleaningOrderMatchesFilter(
        CleaningBookingStatus.inProgress,
        CleaningOrdersListFilter.completed,
      ),
      isFalse,
    );
  });
}
