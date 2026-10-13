import 'package:dllni_user_app/core/models/cleaning_service_extras.dart';
import 'package:dllni_user_app/features/cl_main/view/widgets/cl_cleaning_materials_step_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('material categories start collapsed and quantities are Arabic', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final missing = <int>{};
    final line = CleaningMaterialLineModel.fromJson(const {
      'materialTypeId': 8,
      'name': 'منظف أرضيات',
      'categoryKey': 'cleaners',
      'quantity': 0.1,
      'unit': 'liter',
      'unitLabel': 'لتر',
      'totalPrice': 1.8,
    });
    expect(line.categoryKey, 'cleaners');
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SingleChildScrollView(
              child: ClCleaningMaterialsStepWidget(
                customerProvides: true,
                requiredMaterials: [line],
                missingTypeIds: missing,
                onCustomerProvidesChanged: (_) {},
                onMissingChanged: missing.addAll,
                isLoading: false,
                onRetry: () {},
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.text('منظفات الأسطح'), findsOneWidget);
    expect(find.text('منظف أرضيات'), findsNothing);
    await tester.tap(find.text('منظفات الأسطح'));
    await tester.pumpAndSettle();
    expect(find.text('منظف أرضيات'), findsOneWidget);
    expect(find.text('الكمية المطلوبة: 100 مل'), findsOneWidget);
    expect(find.text('تكلفة المادة: 1.8 ل.س'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
