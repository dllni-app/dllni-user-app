import 'package:dllni_user_app/features/profile/view/widgets/notification_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ignores legacy event booking cleaning notifications', (
    tester,
  ) async {
    await tester.pumpWidget(
      _NotificationNavigationHarness(
        payload: const <String, dynamic>{
          'bookingType': 'event_booking',
          'bookingId': 44,
          'deep_link_target': 'cleaning_order_details',
        },
      ),
    );

    await tester.tap(find.byKey(const Key('navigate')));
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
    expect(find.text('cleaning details'), findsNothing);
  });

  testWidgets('keeps cleaning booking notification navigation', (tester) async {
    await tester.pumpWidget(
      _NotificationNavigationHarness(
        payload: const <String, dynamic>{
          'bookingType': 'cleaning_booking',
          'bookingId': 45,
          'deep_link_target': 'cleaning_order_details',
        },
      ),
    );

    await tester.tap(find.byKey(const Key('navigate')));
    await tester.pumpAndSettle();

    expect(find.text('cleaning details'), findsOneWidget);
  });

  testWidgets(
    'opens cleaning details for preferred-worker decision-required notification',
    (tester) async {
      await tester.pumpWidget(
        _NotificationNavigationHarness(
          payload: const <String, dynamic>{
            'canonicalType':
                'cleaning.booking.preferred_worker_rejected_decision_required',
            'bookingId': 46,
            'deep_link_target': 'cleaning_order_details',
          },
        ),
      );

      await tester.tap(find.byKey(const Key('navigate')));
      await tester.pumpAndSettle();

      expect(find.text('cleaning details'), findsOneWidget);
    },
  );
}

class _NotificationNavigationHarness extends StatelessWidget {
  const _NotificationNavigationHarness({required this.payload});

  final Map<String, dynamic> payload;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: <String, WidgetBuilder>{
        '/cleaning-order-details': (_) =>
            const Scaffold(body: Text('cleaning details')),
      },
      home: Builder(
        builder: (context) {
          return Scaffold(
            body: Column(
              children: <Widget>[
                const Text('home'),
                TextButton(
                  key: const Key('navigate'),
                  onPressed: () => tryNavigateFromNotificationPayload(
                    context,
                    module: 'cleaning',
                    data: payload,
                  ),
                  child: const Text('navigate'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
