import 'package:dllni_user_app/features/orders/data/models/cleaning_orders_api_models.dart';
import 'package:dllni_user_app/features/orders/view/widgets/cleaning_team_search_banner_widget.dart';
import 'package:dllni_user_app/features/orders/view/widgets/cleaning_order_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Cleaning v5 urgency contract', () {
    test('list/detail parse API-authoritative hot-order flag', () {
      final list = CleaningOrderModel.fromJson({
        'id': 42,
        'status': 'pending',
        'isHotOrder': true,
        'assignmentMode': 'open_count',
        'numberOfWorkers': 2,
      });
      final detail = CleaningOrderDetailModel.fromJson({
        'id': 42,
        'status': 'pending',
        'is_hot_order': true,
        'number_of_workers': 2,
      });
      expect(list.isHotOrder, isTrue);
      expect(detail.isHotOrder, isTrue);
      expect(detail.toCleaningOrderModel().isHotOrder, isTrue);
    });

    test('legacy API responses safely default to nonurgent', () {
      final list = CleaningOrderModel.fromJson({'id': 11});
      final detail = CleaningOrderDetailModel.fromJson({'id': 11});
      expect(list.isHotOrder, isFalse);
      expect(detail.isHotOrder, isFalse);
    });
  });

  group('Cleaning v5 team search', () {
    Future<void> showBanner(
      WidgetTester tester, {
      required bool isHotOrder,
      CleaningWorkerAcceptanceModel? acceptance,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: SingleChildScrollView(
                child: CleaningTeamSearchBannerWidget(
                  isHotOrder: isHotOrder,
                  acceptance: acceptance,
                  numberOfWorkers: 2,
                ),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('matching status hides internal radius and timing', (
      tester,
    ) async {
      await showBanner(
        tester,
        isHotOrder: false,
        acceptance: CleaningWorkerAcceptanceModel(
          accepted: 1,
          remaining: 1,
          required: 2,
        ),
      );
      expect(find.text('انضم عامل إلى طلبك'), findsOneWidget);
      expect(find.textContaining('15 دقيقة'), findsNothing);
      expect(find.textContaining('50 كم'), findsNothing);
      expect(find.textContaining('10 كم'), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('urgent search only shows status and notification promise', (
      tester,
    ) async {
      await showBanner(
        tester,
        isHotOrder: true,
        acceptance: CleaningWorkerAcceptanceModel(
          accepted: 0,
          required: 2,
          remaining: 2,
        ),
      );
      expect(find.text('طلبك المستعجل قيد المتابعة'), findsOneWidget);
      expect(find.textContaining('سنرسل إليك إشعاراً'), findsOneWidget);
      expect(find.textContaining('50 كم'), findsNothing);
      expect(find.textContaining('15 دقيقة'), findsNothing);
    });
  });

  group('Cleaning v5 order card', () {
    testWidgets('urgent order label and follow-up action use API urgency', (
      tester,
    ) async {
      var tapped = false;
      final order = CleaningOrderModel.fromJson({
        'id': 42,
        'status': 'pending',
        'propertyType': 'apartment',
        'assignmentMode': 'open_count',
        'numberOfWorkers': 2,
        'isHotOrder': true,
      });
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: CleaningOrderCard(order: order, onTap: () => tapped = true),
            ),
          ),
        ),
      );
      expect(find.textContaining('المستعجل'), findsOneWidget);
      await tester.tap(find.text('متابعة الطلب'));
      expect(tapped, isTrue);
    });

    testWidgets('regular card only shows the customer-facing matching status', (
      tester,
    ) async {
      final order = CleaningOrderModel.fromJson({
        'id': 43,
        'status': 'pending',
        'propertyType': 'apartment',
        'assignmentMode': 'open_count',
        'numberOfWorkers': 2,
        'workerAcceptance': {
          'required': 2,
          'accepted': 0,
          'remaining': 2,
          'isFulfilled': false,
        },
      });
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CleaningOrderCard(order: order)),
        ),
      );
      expect(find.textContaining('(0/2)'), findsNothing);
      expect(find.textContaining('جارٍ البحث عن عامل مناسب'), findsOneWidget);
    });
  });
}
