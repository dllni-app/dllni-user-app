import 'package:dllni_user_app/features/orders/view/widgets/cleaning_start_verification_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('start verification never offers cancellation for a booking', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    var submitted = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  CleaningStartVerificationDialog.show(
                    context,
                    bookingId: 123,
                    bookingNumber: 'CLN-123',
                    onSubmit: (code) async {
                      submitted++;
                      return null;
                    },
                  );
                },
                child: const Text('افتح رمز الأمان'),
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('افتح رمز الأمان'));
    await tester.pumpAndSettle();
    expect(find.text('إلغاء الطلب'), findsNothing);
    expect(find.text('رقم الحجز: CLN-123'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(4));
    for (var i = 0; i < 3; i++) {
      await tester.enterText(find.byType(TextField).at(i), '${i + 1}');
      await tester.pump();
    }
    expect(submitted, 0);
    await tester.tap(find.text('ليس الآن'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

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
