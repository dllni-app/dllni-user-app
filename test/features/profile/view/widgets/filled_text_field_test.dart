import 'package:dllni_user_app/features/profile/view/widgets/filled_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows a red required marker when the field is required', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FilledTextField(
            label: 'المدينة',
            isRequired: true,
            controller: controller,
          ),
        ),
      ),
    );

    expect(find.text('المدينة'), findsOneWidget);
    expect(find.text('*'), findsOneWidget);
  });
}
