import 'package:dllni_user_app/core/models/cleaning_service_extras.dart';
import 'package:dllni_user_app/features/cl_main/data/models/cleaning_services_response_model.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/cl_cleaning_extras_section_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'edits decimal item details per special service in RTL dark large-text layout',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(375, 1600);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final semantics = tester.ensureSemantics();

      const catalog = CleaningServiceModel(
        id: 9,
        name: 'تنظيف كنب',
        category: 'special_service',
        inputType: 'decimal',
        unitCode: 'm2',
        supportsDirtiness: true,
        dirtinessRules: <CleaningServiceDirtinessRuleModel>[
          CleaningServiceDirtinessRuleModel(
            id: 3,
            name: 'اتساخ كثيف',
            slug: 'heavy',
            level: 'heavy',
          ),
        ],
      );
      var request = const CleaningSpecialServiceRequest(
        specialServiceId: 9,
        items: <CleaningSpecialServiceItemRequest>[
          CleaningSpecialServiceItemRequest(quantity: 1, dirtinessLevelId: 3),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1E2A78),
              brightness: Brightness.dark,
            ),
          ),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: MediaQuery(
              data: const MediaQueryData(
                size: Size(375, 1600),
                textScaler: TextScaler.linear(2),
              ),
              child: Scaffold(
                body: StatefulBuilder(
                  builder: (context, setState) => SingleChildScrollView(
                    child: ClCleaningExtrasSectionWidget(
                      requestMaterials: false,
                      specialServices: <CleaningSpecialServiceRequest>[request],
                      openTime: null,
                      availableSpecialServices: const <CleaningServiceModel>[
                        catalog,
                      ],
                      materials: const <CleaningMaterialLineModel>[],
                      estimatedSpecialServices:
                          const <CleaningSpecialServiceLineModel>[],
                      estimatedOpenTime: null,
                      isSpecialServicesLoading: false,
                      isEstimateLoading: false,
                      onRequestMaterialsChanged: (_) {},
                      onAddSpecialService: () {},
                      onSpecialServiceChanged: (_, value) => setState(() {
                        request = value;
                      }),
                      onRemoveSpecialService: (_) {},
                      onOpenTimeChanged: (_) {},
                      onOpenTimeWorkerCountChanged: (_) {},
                      onOpenTimeExpectedMaxMinutesChanged: (_) {},
                      onRetryEstimate: () {},
                      onRetrySpecialServices: () {},
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'عناصر الخدمة الخاصة',
        ),
        findsOneWidget,
      );
      expect(find.text('العنصر 1'), findsOneWidget);
      expect(find.text('مستوى الاتساخ لهذا العنصر'), findsOneWidget);
      expect(tester.takeException(), isNull);

      final addItemButton = find.byKey(
        const ValueKey<String>('special-service-9-add-item'),
      );
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, -1200),
      );
      await tester.pump();
      await tester.tap(addItemButton.first);
      await tester.pump();
      expect(find.text('العنصر 2'), findsOneWidget);
      expect(request.items, hasLength(2));

      await tester.ensureVisible(find.byType(TextFormField).first);
      await tester.enterText(find.byType(TextFormField).first, '2.75');
      await tester.pump();
      expect(request.items.first.quantity, 2.75);

      expect(
        tester.getSize(addItemButton.first).height,
        greaterThanOrEqualTo(48),
      );
      expect(tester.takeException(), isNull);
      semantics.dispose();
    },
  );
}
