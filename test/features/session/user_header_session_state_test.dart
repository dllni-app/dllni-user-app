import 'package:dllni_user_app/core/session/user_session_store.dart';
import 'package:dllni_user_app/features/auth/data/models/login_response_model.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/cl_home_app_bar.dart';
import 'package:dllni_user_app/features/sm_home/view/widgets/home_app_bar.dart'
    as sm_home;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    UserSessionStore.userNotifier.value = null;
  });

  Future<void> pumpAppBar(WidgetTester tester, Widget appBar) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(padding: EdgeInsets.zero),
          child: Scaffold(body: appBar),
        ),
      ),
    );
    await tester.pump();
  }

  group('header username session state', () {
    testWidgets('cleaning home header renders saved user name', (tester) async {
      UserSessionStore.userNotifier.value =
          LoggedInUserModel(name: 'Cleaning User');

      await pumpAppBar(tester, const ClHomeAppBar());

      expect(find.text('Cleaning User'), findsOneWidget);
      expect(find.text('أحمد محمد'), findsNothing);
    });

    testWidgets('supermarket home header renders saved user name', (tester) async {
      UserSessionStore.userNotifier.value =
          LoggedInUserModel(name: 'Market User');

      await pumpAppBar(tester, const sm_home.HomeAppBar());

      expect(find.text('Market User'), findsOneWidget);
      expect(find.text('أحمد محمد'), findsNothing);
    });

    testWidgets('empty name renders placeholder', (tester) async {
      UserSessionStore.userNotifier.value = LoggedInUserModel(name: '  ');

      await pumpAppBar(tester, const ClHomeAppBar());

      expect(find.text(UserSessionStore.defaultDisplayNamePlaceholder),
          findsOneWidget);
    });

    testWidgets('notifier update changes header text', (tester) async {
      UserSessionStore.userNotifier.value = LoggedInUserModel(name: 'Before');

      await pumpAppBar(tester, const ClHomeAppBar());
      expect(find.text('Before'), findsOneWidget);

      UserSessionStore.userNotifier.value = LoggedInUserModel(name: 'After');
      await tester.pump();

      expect(find.text('After'), findsOneWidget);
      expect(find.text('Before'), findsNothing);
    });
  });
}
