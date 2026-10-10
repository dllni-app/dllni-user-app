import 'package:dllni_user_app/features/orders/view/widgets/cleaning_start_verification_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('verification dialog can close safely without booking number', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    Future<bool>? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  result = CleaningStartVerificationDialog.show(
                    context,
                    onSubmit: (code) async => null,
                  );
                },
                child: const Text('فتح التحقق'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('فتح التحقق'));
    await tester.pumpAndSettle();
    expect(find.text('تأكيد بدء العمل'), findsOneWidget);
    expect(find.text('ليس الآن'), findsOneWidget);
    expect(find.text('إلغاء الطلب'), findsNothing);

    await tester.tap(find.text('ليس الآن'));
    await tester.pumpAndSettle();
    expect(await result, isFalse);
    expect(tester.takeException(), isNull);
  });
}
