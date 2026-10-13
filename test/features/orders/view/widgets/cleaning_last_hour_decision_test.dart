import 'package:dllni_user_app/features/orders/data/models/cleaning_orders_api_models.dart';
import 'package:dllni_user_app/features/orders/view/widgets/cleaning_last_hour_team_decision_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('order model reads last-hour decision from the API', () {
    final model = CleaningOrderDetailModel.fromJson({
      'id': 58,
      'status': 'pending',
      'lastHourTeamDecision': {
        'required': true,
        'acceptedWorkers': 1,
        'requiredWorkers': 2,
        'workerIds': [19],
      },
    });
    expect(model.lastHourTeamDecision?['required'], true);
    expect(model.lastHourTeamDecision?['workerIds'], [19]);
  });

  Widget buildCard({
    required Map<String, dynamic> decision,
    required Future<void> Function(String, int?) onChoose,
  }) {
    return MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: SingleChildScrollView(
            child: CleaningLastHourTeamDecisionCard(
              decision: decision,
              onChoose: onChoose,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('assign-all requires explicit confirmation and sends worker ID', (
    tester,
  ) async {
    String? selectedChoice;
    int? selectedWorker;
    await tester.pumpWidget(
      buildCard(
        decision: const {
          'required': true,
          'workerIds': [19],
        },
        onChoose: (choice, workerId) async {
          selectedChoice = choice;
          selectedWorker = workerId;
        },
      ),
    );

    await tester.tap(find.byKey(const Key('cleaning_last_hour_assign_all')));
    await tester.pumpAndSettle();
    expect(selectedChoice, isNull);
    expect(find.textContaining('إسناد جميع مهام الطلب'), findsOneWidget);
    await tester.tap(find.byKey(const Key('cleaning_last_hour_dismiss')));
    await tester.pumpAndSettle();
    expect(selectedChoice, isNull);

    await tester.tap(find.byKey(const Key('cleaning_last_hour_assign_all')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('cleaning_last_hour_confirm')));
    await tester.pumpAndSettle();
    expect(selectedChoice, 'all_tasks');
    expect(selectedWorker, 19);
    expect(tester.takeException(), isNull);
  });

  testWidgets('multiple accepted workers cannot get all-tasks choice', (
    tester,
  ) async {
    String? selectedChoice;
    await tester.pumpWidget(
      buildCard(
        decision: const {
          'required': true,
          'workerIds': [19, 25],
        },
        onChoose: (choice, workerId) async => selectedChoice = choice,
      ),
    );

    expect(
      find.byKey(const Key('cleaning_last_hour_assign_all')),
      findsNothing,
    );
    await tester.tap(
      find.byKey(const Key('cleaning_last_hour_keep_assignment')),
    );
    await tester.pumpAndSettle();
    expect(selectedChoice, isNull);
    await tester.tap(find.byKey(const Key('cleaning_last_hour_confirm')));
    await tester.pumpAndSettle();
    expect(selectedChoice, 'assigned_only');
  });

  testWidgets('decision is not shown when backend says unavailable', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildCard(
        decision: const {
          'required': false,
          'workerIds': [19],
        },
        onChoose: (choice, workerId) async {},
      ),
    );
    expect(find.byKey(const Key('cleaning_last_hour_decision')), findsNothing);
  });
}
