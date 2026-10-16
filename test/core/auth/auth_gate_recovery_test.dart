import 'package:dllni_user_app/core/auth/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(AuthGate.clearPendingAction);

  testWidgets(
    'expired-session login restores the pending booking after its old route was removed',
    (tester) async {
      final navigator = GlobalKey<NavigatorState>();
      final retainedDraft = <String, Object>{
        'roomKey': 'bedroom.2',
        'workers': 3,
      };
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigator,
          home: const Scaffold(body: Text('الحجز السابق')),
          routes: {
            '/login': (context) => Scaffold(
              body: TextButton(
                onPressed: () => AuthGate.resumePendingActionIfAny(context),
                child: const Text('تم تسجيل الدخول'),
              ),
            ),
          },
        ),
      );
      AuthGate.rememberAction(() {
        navigator.currentState!.pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => Scaffold(
              body: Text(
                '${retainedDraft['roomKey']} / ${retainedDraft['workers']}',
              ),
            ),
          ),
        );
      });
      navigator.currentState!.pushNamedAndRemoveUntil('/login', (_) => false);
      await tester.pumpAndSettle();
      expect(find.text('الحجز السابق'), findsNothing);
      await tester.tap(find.text('تم تسجيل الدخول'));
      await tester.pumpAndSettle();
      expect(find.text('bedroom.2 / 3'), findsOneWidget);
      expect(find.text('تم تسجيل الدخول'), findsNothing);

      final restoredContext = tester.element(find.text('bedroom.2 / 3'));
      expect(await AuthGate.resumePendingActionIfAny(restoredContext), isFalse);
    },
  );
}
