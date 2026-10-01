import 'package:dllni_user_app/features/profile/domain/models/address_list_item.dart';
import 'package:dllni_user_app/features/profile/view/widgets/address_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const address = AddressListItem(
    id: '7',
    label: 'المنزل',
    line1: 'حلب، الفرقان',
    type: AddressType.home,
    city: 'حلب',
    neighborhood: 'الفرقان',
    landmark: 'جانب الحديقة',
  );

  testWidgets('default address keeps edit and delete actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AddressCard(item: address, isDefault: true)),
      ),
    );

    expect(find.text('افتراضي'), findsOneWidget);
    expect(find.text('تعديل'), findsOneWidget);
    expect(find.text('حذف'), findsOneWidget);
    expect(find.text('تعيين كافتراضي'), findsNothing);
  });

  testWidgets('selection mode exposes the choose affordance', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AddressCard(
            item: address,
            isDefault: false,
            showActions: false,
          ),
        ),
      ),
    );

    expect(find.text('اختيار هذا العنوان'), findsOneWidget);
    expect(find.text('تعديل'), findsNothing);
    expect(find.text('حذف'), findsNothing);
  });
}
