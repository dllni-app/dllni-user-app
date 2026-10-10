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

  testWidgets('customer can assign all tasks to the accepted worker', (
    tester,
  ) async {
    String? selectedChoice;
    int? selectedWorker;
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SingleChildScrollView(
              child: CleaningLastHourTeamDecisionCard(
                decision: const {
                  'required': true,
                  'workerIds': [19],
                },
                onChoose: (choice, workerId) async {
                  selectedChoice = choice;
                  selectedWorker = workerId;
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('cleaning_last_hour_assign_all')));
    expect(selectedChoice, 'all_tasks');
    expect(selectedWorker, 19);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'customer can retain assigned tasks with multiple accepted workers',
    (tester) async {
      String? selectedChoice;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CleaningLastHourTeamDecisionCard(
                decision: const {
                  'required': true,
                  'workerIds': [19, 25],
                },
                onChoose: (choice, workerId) async => selectedChoice = choice,
              ),
            ),
          ),
        ),
      );
      final allButton = tester.widget<FilledButton>(
        find.byKey(const Key('cleaning_last_hour_assign_all')),
      );
      expect(allButton.onPressed, isNull);
      await tester.tap(
        find.byKey(const Key('cleaning_last_hour_keep_assignment')),
      );
      expect(selectedChoice, 'assigned_only');
    },
  );

  testWidgets('decision is not shown when backend says it is unavailable', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CleaningLastHourTeamDecisionCard(
            decision: const {
              'required': false,
              'workerIds': [19],
            },
            onChoose: (choice, workerId) async {},
          ),
        ),
      ),
    );
    expect(find.byKey(const Key('cleaning_last_hour_decision')), findsNothing);
  });
}
