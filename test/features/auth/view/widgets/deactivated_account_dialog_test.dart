import 'package:dllni_user_app/features/auth/view/widgets/deactivated_account_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the deactivated account message and closes explicitly', (
    tester,
  ) async {
    const message = 'تم إلغاء تفعيل حسابك. يرجى التواصل مع الدعم.';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (_) => const DeactivatedAccountDialog(
                  message: message,
                ),
              ),
              child: const Text('فتح'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('فتح'));
    await tester.pumpAndSettle();

    expect(find.text('تم إلغاء تفعيل الحساب'), findsOneWidget);
    expect(find.text(message), findsOneWidget);
    expect(find.text('حسناً'), findsOneWidget);

    await tester.tap(find.text('حسناً'));
    await tester.pumpAndSettle();

    expect(find.text('تم إلغاء تفعيل الحساب'), findsNothing);
  });
}
