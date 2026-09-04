import 'package:dllni_user_app/features/orders/data/models/cleaning_booking_schedule_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses recurring schedule revision price reconfirmation preview', () {
    final preview = cleaningRecurringScheduleRevisionPreviewFromJson({
      'success': true,
      'data': {
        'revision': {
          'revisionToken': 'a' * 64,
          'requiresReconfirmation': true,
          'scheduleChanged': true,
          'priceChanged': true,
          'oldTotal': 300,
          'newTotal': 400,
          'priceDelta': 100,
          'discountAmount': 25,
          'currency': 'SYP',
          'editableSessionsCount': 3,
          'preservedSessionsCount': 1,
          'proposedSessionsCount': 4,
          'sessionHours': 2.5,
        },
      },
    });

    expect(preview.revisionToken, hasLength(64));
    expect(preview.requiresReconfirmation, isTrue);
    expect(preview.scheduleChanged, isTrue);
    expect(preview.priceChanged, isTrue);
    expect(preview.oldTotal, 300);
    expect(preview.newTotal, 400);
    expect(preview.priceDelta, 100);
    expect(preview.discountAmount, 25);
    expect(preview.currency, 'SYP');
    expect(preview.editableSessionsCount, 3);
    expect(preview.preservedSessionsCount, 1);
    expect(preview.proposedSessionsCount, 4);
    expect(preview.sessionHours, 2.5);
  });
}
