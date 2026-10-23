import 'package:dllni_user_app/core/session/user_session_store.dart';
import 'package:dllni_user_app/features/sm_home/view/widgets/home_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'supermarket guest header never displays an account placeholder',
    (tester) async {
      UserSessionStore.userNotifier.value = null;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: HomeAppBar())),
        ),
      );

      expect(find.text('مرحباً بك 👋'), findsOneWidget);
      expect(find.text('زائر'), findsOneWidget);
      expect(find.text('اسم المستخدم'), findsNothing);
      expect(find.text('مرحباً بعودتك 👋'), findsNothing);
    },
  );
}
