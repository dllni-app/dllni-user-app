import 'package:dllni_user_app/core/themes/shared_platform_colors.dart';
import 'package:dllni_user_app/core/widgets/success_action_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('success sheet remains usable in narrow RTL layouts', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    var followUpCalls = 0;
    var shareCalls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => SuccessActionBottomSheet(
                    title: 'تم إتمام الطلب بنجاح',
                    followUpLabel: 'متابعة تفاصيل الطلب',
                    shareLabel: 'مشاركة الطلب',
                    onFollowUp: () => followUpCalls++,
                    onShare: () => shareCalls++,
                  ),
                ),
                child: const Text('فتح'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('فتح'));
    await tester.pumpAndSettle();
    expect(find.text('تم إتمام الطلب بنجاح'), findsOneWidget);
    expect(find.byIcon(Icons.verified_rounded), findsOneWidget);
    final icon = tester.widget<Icon>(find.byIcon(Icons.verified_rounded));
    expect(icon.color, SharedPlatformColors.success);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('متابعة تفاصيل الطلب'));
    await tester.tap(find.text('متابعة تفاصيل الطلب'));
    expect(followUpCalls, 1);

    await tester.ensureVisible(find.text('مشاركة الطلب'));
    await tester.tap(find.text('مشاركة الطلب'));
    expect(shareCalls, 1);
    expect(tester.takeException(), isNull);
  });
}
