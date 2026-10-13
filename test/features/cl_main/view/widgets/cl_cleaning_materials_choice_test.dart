import 'package:dllni_user_app/features/cl_main/view/widgets/cl_cleaning_extras_section_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('customer can choose who supplies cleaning materials', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var requestMaterials = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => SingleChildScrollView(
                child: ClCleaningExtrasSectionWidget(
                  requestMaterials: requestMaterials,
                  specialServices: const [],
                  openTime: null,
                  availableSpecialServices: const [],
                  materials: const [],
                  estimatedSpecialServices: const [],
                  estimatedOpenTime: null,
                  isSpecialServicesLoading: false,
                  isEstimateLoading: false,
                  showOpenTime: false,
                  onRequestMaterialsChanged: (next) {
                    setState(() => requestMaterials = next);
                  },
                  onAddSpecialService: () {},
                  onSpecialServiceChanged: (index, service) {},
                  onRemoveSpecialService: (index) {},
                  onOpenTimeChanged: (enabled) {},
                  onOpenTimeWorkerCountChanged: (count) {},
                  onOpenTimeExpectedMaxMinutesChanged: (minutes) {},
                  onRetryEstimate: () {},
                  onRetrySpecialServices: () {},
                ),
              ),
            ),
          ),
        ),
      ),
    );

    const serviceKey = Key('cleaning_materials_from_service');
    const customerKey = Key('cleaning_materials_from_customer');

    expect(find.byKey(serviceKey), findsOneWidget);
    expect(find.byKey(customerKey), findsOneWidget);
    expect(requestMaterials, isFalse);

    await tester.tap(find.byKey(serviceKey));
    await tester.pumpAndSettle();
    expect(requestMaterials, isTrue);

    await tester.tap(find.byKey(customerKey));
    await tester.pumpAndSettle();
    expect(requestMaterials, isFalse);
    expect(tester.takeException(), isNull);
  });
}
