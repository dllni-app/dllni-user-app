import 'package:dllni_user_app/core/models/cleaning_service_extras.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/cl_cleaning_materials_step_widget.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/cl_special_services_step_widget.dart';
import 'package:dllni_user_app/features/cl_main/data/models/cleaning_services_response_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'material request includes selected missing types in the server payload',
    () {
      const all = CleaningServiceExtrasRequest(requestMaterials: true);
      const missing = CleaningServiceExtrasRequest(
        requestMaterials: true,
        materialTypeIds: [31, 42],
      );
      const customer = CleaningServiceExtrasRequest(requestMaterials: false);
      expect((all.toJson()['materials'] as Map)['providedByPlatform'], true);
      expect(
        (all.toJson()['materials'] as Map).containsKey('materialTypeIds'),
        false,
      );
      expect((missing.toJson()['materials'] as Map)['materialTypeIds'], [
        31,
        42,
      ]);
      expect(
        (customer.toJson()['materials'] as Map)['providedByPlatform'],
        false,
      );
      expect(
        missing.copyWith(clearMaterialTypeIds: true).materialTypeIds,
        isNull,
      );
    },
  );

  for (final width in [320.0, 390.0]) {
    testWidgets(
      'materials page shows required quantities and selects only missing at $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 850);
        tester.view.devicePixelRatio = 1;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });
        bool customerProvides = true;
        Set<int> missing = {};
        await tester.pumpWidget(
          MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: SingleChildScrollView(
                  child: StatefulBuilder(
                    builder: (context, setState) =>
                        ClCleaningMaterialsStepWidget(
                          customerProvides: customerProvides,
                          missingTypeIds: missing,
                          requiredMaterials: const [
                            CleaningMaterialLineModel(
                              materialTypeId: 31,
                              name: 'منظف الأرض',
                              quantity: 2,
                              unit: 'L',
                              totalPrice: 200,
                            ),
                            CleaningMaterialLineModel(
                              materialTypeId: 42,
                              name: 'معقم الأسطح',
                              quantity: 1,
                              unit: 'L',
                              totalPrice: 150,
                            ),
                          ],
                          isLoading: false,
                          onRetry: () {},
                          onCustomerProvidesChanged: (value) =>
                              setState(() => customerProvides = value),
                          onMissingChanged: (ids) =>
                              setState(() => missing = ids),
                        ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.ensureVisible(find.text('مواد متنوعة'));
        await tester.tap(find.text('مواد متنوعة'));
        await tester.pumpAndSettle();
        expect(find.text('منظف الأرض'), findsOneWidget);
        expect(find.text('معقم الأسطح'), findsOneWidget);
        await tester.ensureVisible(find.byKey(const Key('material_type_31')));
        await tester.tap(find.byKey(const Key('material_type_31')));
        await tester.pump();
        expect(missing, {31});
        await tester.ensureVisible(
          find.byKey(const Key('material_select_all_missing')),
        );
        await tester.tap(find.byKey(const Key('material_select_all_missing')));
        await tester.pump();
        expect(missing, {31, 42});
        await tester.ensureVisible(
          find.byKey(const Key('material_clear_missing')),
        );
        await tester.tap(find.byKey(const Key('material_clear_missing')));
        await tester.pump();
        expect(missing, isEmpty);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('special services can be selected separately', (tester) async {
    final selected = <int>{};
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ClSpecialServicesStepWidget(
              catalog: const [
                CleaningServiceModel(
                  id: 7,
                  name: 'تنظيف الكنب',
                  description: 'تنظيف عميق',
                ),
              ],
              selectedIds: selected,
              onToggle: selected.add,
              isLoading: false,
              editor: const Text('تحديد عدد القطع'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('special_catalog_7')));
    expect(selected, {7});
    expect(tester.takeException(), isNull);
  });
}
