import 'package:dllni_user_app/core/models/cleaning_service_extras.dart';
import 'package:dllni_user_app/features/cl_main/data/models/cleaning_services_response_model.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/cl_special_services_step_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'selected service reveals two dirtiness choices directly below it',
    (tester) async {
      tester.view.physicalSize = const Size(390, 860);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      const catalog = CleaningServiceModel(
        id: 5,
        name: 'تنظيف الثلاجة من الداخل',
        supportsDirtiness: true,
        dirtinessRules: [
          CleaningServiceDirtinessRuleModel(id: 11, level: 'low'),
          CleaningServiceDirtinessRuleModel(id: 12, level: 'medium'),
          CleaningServiceDirtinessRuleModel(id: 13, level: 'high'),
          CleaningServiceDirtinessRuleModel(id: 14, level: 'heavy'),
        ],
      );
      CleaningSpecialServiceRequest selected =
          const CleaningSpecialServiceRequest(
            specialServiceId: 5,
            dirtinessLevel: 'low',
            items: [
              CleaningSpecialServiceItemRequest(
                quantity: 1,
                dirtinessLevelId: 11,
              ),
            ],
          );
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: SingleChildScrollView(
                child: StatefulBuilder(
                  builder: (context, setState) => ClSpecialServicesStepWidget(
                    catalog: const [catalog],
                    selectedIds: const {5},
                    selectedServices: [selected],
                    onServiceChanged: (value) =>
                        setState(() => selected = value),
                    onToggle: (_) {},
                    isLoading: false,
                    editor: const SizedBox(),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.text('تنظيف الثلاجة من الداخل'), findsOneWidget);
      expect(find.text('اتساخ بسيط'), findsOneWidget);
      expect(find.text('اتساخ شديد'), findsOneWidget);
      expect(find.text('اتساخ عادي'), findsNothing);
      expect(find.text('العنصر 1'), findsNothing);
      expect(find.text('حدد تفاصيل القطع'), findsNothing);
      expect(find.byKey(const Key('special_config_5')), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('special_heavy_5')));
      await tester.tap(find.byKey(const Key('special_heavy_5')));
      await tester.pump();
      expect(selected.items.single.dirtinessLevelId, 14);
      expect(selected.dirtinessLevel, 'heavy');
      await tester.tap(find.byKey(const Key('special_increase_5')));
      await tester.pump();
      expect(selected.quantity, 2);
      expect(selected.items.single.quantity, 2);
      expect(tester.takeException(), isNull);
    },
  );
}
