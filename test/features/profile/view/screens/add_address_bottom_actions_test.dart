import 'package:dllni_user_app/features/profile/view/screens/add_address_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpActions(WidgetTester tester, {required double width}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Center(
            child: SizedBox(
              width: width,
              child: AddAddressBottomActions(
                isSubmitting: false,
                submitLabel: 'أضف العنوان',
                onSubmitPressed: () {},
                onCancelPressed: () {},
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('uses wider horizontal cancel button on normal width', (
    tester,
  ) async {
    await _pumpActions(tester, width: 420);

    expect(find.text('إلغاء'), findsOneWidget);

    final submitSize = tester.getSize(
      find.byKey(AddAddressBottomActions.submitButtonKey),
    );
    final cancelSize = tester.getSize(
      find.byKey(AddAddressBottomActions.cancelButtonKey),
    );

    expect(cancelSize.width, greaterThan(120));
    expect(submitSize.width, greaterThan(cancelSize.width));
    expect(submitSize.height, cancelSize.height);
  });

  testWidgets('stacks full-width actions on very narrow width', (tester) async {
    await _pumpActions(tester, width: 280);

    final submitFinder = find.byKey(AddAddressBottomActions.submitButtonKey);
    final cancelFinder = find.byKey(AddAddressBottomActions.cancelButtonKey);

    expect(find.text('إلغاء'), findsOneWidget);
    expect(tester.getSize(submitFinder).width, 280);
    expect(tester.getSize(cancelFinder).width, 280);
    expect(
      tester.getTopLeft(cancelFinder).dy,
      greaterThan(tester.getBottomLeft(submitFinder).dy),
    );
  });
}
