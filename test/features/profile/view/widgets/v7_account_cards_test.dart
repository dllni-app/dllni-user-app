import 'package:dllni_user_app/features/profile/domain/models/address_list_item.dart';
import 'package:dllni_user_app/features/profile/view/widgets/address_card.dart';
import 'package:dllni_user_app/features/profile/data/models/fetch_notifications_model.dart';
import 'package:dllni_user_app/features/profile/view/widgets/notification_feed_item.dart';
import 'package:dllni_user_app/features/profile/data/models/platform_coupon_models.dart';
import 'package:dllni_user_app/features/profile/view/widgets/platform_coupon_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('address panel retains selection, edit and delete actions', (
    tester,
  ) async {
    var setDefault = 0;
    var edits = 0;
    var deletes = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SingleChildScrollView(
              child: AddressCard(
                item: const AddressListItem(
                  id: '4',
                  label: 'المنزل',
                  line1: 'شارع المدينة',
                  type: AddressType.home,
                ),
                isDefault: false,
                onSetDefault: () => setDefault++,
                onEdit: () => edits++,
                onDelete: () => deletes++,
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.text('المنزل'), findsOneWidget);
    await tester.tap(find.text('جعله افتراضياً'));
    await tester.tap(find.text('تعديل'));
    await tester.tap(find.text('حذف'));
    expect([setDefault, edits, deletes], [1, 1, 1]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unread notification displays real message in RTL', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: NotificationFeedItem(
              notification: FetchNotificationsModelDataItem(
                type: 'cleaning.booking.accepted',
                title: 'تم قبول طلبك',
                body: 'قبل العامل طلبك',
                isRead: false,
                category: 'orders',
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.text('تم قبول طلبك'), findsOneWidget);
    expect(find.text('قبل العامل طلبك'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('coupon displays server price and copy action', (tester) async {
    final model = PlatformCouponModel.fromJson({
      'id': 23,
      'code': 'SAVE15',
      'title': 'عرض التنظيف',
      'description': 'لفترة محدودة',
      'section': 'cleaning',
      'discount': {'type': 'percentage', 'value': 15},
      'minOrderAmount': 10000,
      'appliesTo': <String, dynamic>{},
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: PlatformCouponCard(coupon: model)),
        ),
      ),
    );
    expect(find.text('SAVE15'), findsOneWidget);
    expect(find.text('15%'), findsOneWidget);
    await tester.tap(find.byTooltip('نسخ الرمز'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
