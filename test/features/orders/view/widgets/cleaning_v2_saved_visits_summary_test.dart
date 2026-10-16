import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dllni_user_app/features/orders/data/models/cleaning_orders_api_models.dart';
import 'package:dllni_user_app/features/orders/view/widgets/cleaning_time_periods_summary.dart';

void main() {
  testWidgets(
    'V2 details show visits, rooms, materials and targeted services but no periods',
    (tester) async {
      final order = CleaningOrderDetailModel(
        contractVersion: 2,
        bookingRooms: const [
          {
            'roomKey': 'bedroom.1',
            'roomType': 'bedroom',
            'size': 'medium',
            'cleaningMode': 'regular',
          },
        ],
        bookingVisits: const [
          {
            'sequence': 1,
            'roomSchedules': [
              {
                'scheduleKey': 's1',
                'roomKey': 'bedroom.1',
                'scheduledDate': '2026-10-17',
                'startAt': '2026-10-17T09:00:00',
                'endAt': '2026-10-17T09:35:00',
                'numberOfWorkers': 2,
              },
            ],
            'timePeriods': [
              {
                'periodKey': 'p1',
                'materials': {
                  'choice': 'customer_partial',
                  'materialTypeIds': [1],
                },
                'platformMaterials': [
                  {
                    'materialTypeId': 1,
                    'name': 'منظف الأرضيات',
                    'quantity': 1,
                    'unit': 'pack',
                  },
                ],
                'specialServices': [
                  {
                    'specialServiceId': 8,
                    'name': 'تنظيف النوافذ',
                    'targetRoomKeys': ['bedroom.1'],
                    'quantity': 1,
                    'dirtinessLevel': 'heavy',
                  },
                ],
              },
            ],
          },
        ],
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CleaningTimePeriodsSummary(order: order),
            ),
          ),
        ),
      );
      expect(find.text('مواعيد الخدمة وتفاصيل الغرف'), findsOneWidget);
      expect(find.textContaining('الزيارة 1'), findsOneWidget);
      expect(find.textContaining('غرفة نوم 1'), findsWidgets);
      expect(find.textContaining('حوسة'), findsOneWidget);
      expect(find.textContaining('العمال: 2'), findsOneWidget);
      expect(find.textContaining('توفير المواد الناقصة'), findsOneWidget);
      expect(find.textContaining('من 09:00 إلى 09:35'), findsOneWidget);
      expect(find.textContaining('عبوة'), findsOneWidget);
      expect(find.textContaining('pack'), findsNothing);
      expect(find.textContaining('تنظيف النوافذ'), findsOneWidget);
      expect(find.textContaining('اتساخ شديد'), findsOneWidget);
      expect(find.textContaining('فترات العمل'), findsNothing);
      expect(find.textContaining('p1'), findsNothing);
    },
  );
}
