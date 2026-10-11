import 'package:dllni_user_app/features/cl_main/data/models/cleaning_suite_config_model.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_room_size_breakdown.dart';
import 'package:dllni_user_app/features/cl_main/view/helpers/cl_event_collected_fields.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/cl_booking_review_overview.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/home_details_app_bar.dart';
import 'package:dllni_user_app/features/orders/data/models/cleaning_booking_status.dart';
import 'package:dllni_user_app/features/orders/view/widgets/cleaning_lifecycle_timeline_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const guests = CleaningDynamicFieldConfigModel(
    id: 20,
    key: 'guest_count',
    label: 'عدد الضيوف',
    type: 'number',
    required: true,
  );
  const note = CleaningDynamicFieldConfigModel(
    id: 22,
    key: 'venue_type',
    label: 'نوع المكان',
    type: 'text',
    required: true,
  );

  test(
    'occasion guest answer uses previously chosen count and retains other fields',
    () {
      expect(isPreviouslyCollectedGuestCount(guests), isTrue);
      expect(isPreviouslyCollectedGuestCount(note), isFalse);
      final merged = mergeCollectedGuestsIntoDynamicAnswers(
        fields: const [guests, note],
        answers: const {'venue_type': 'صالة', 'guest_count': 99},
        guestCount: 10,
      );
      expect(merged['guest_count'], 10);
      expect(merged['venue_type'], 'صالة');
    },
  );

  testWidgets('booking review includes real room counts', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SingleChildScrollView(
              child: ClBookingReviewOverview(
                service: 'تنظيف عادي',
                address: 'المنزل',
                workerLabel: '1',
                materialsRequested: false,
                services: [],
                roomSizeBreakdown: CleaningRoomSizeBreakdown(
                  bedroom: CleaningRoomSizeBucket(medium: 1),
                  bathroom: CleaningRoomSizeBucket(small: 1),
                  kitchen: CleaningRoomSizeBucket(medium: 1),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.textContaining('غرف النوم: 1'), findsOneWidget);
    expect(find.textContaining('الحمامات: 1'), findsOneWidget);
    expect(find.textContaining('المطابخ: 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('booking header uses owning step handler', (tester) async {
    var backPresses = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: HomeDetailsAppBar(onBack: () => backPresses++)),
      ),
    );
    await tester.tap(find.byTooltip('الرجوع'));
    expect(backPresses, 1);
  });

  test('pending order label is customer-readable, without matching jargon', () {
    final action = cleaningLifecyclePrimaryAction(
      CleaningBookingStatus.pending,
    );
    expect(action.label, 'تحديث حالة الطلب');
    expect(action.kind, CleaningLifecycleActionKind.refreshSearch);
  });
}
