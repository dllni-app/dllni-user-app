import 'package:dllni_user_app/features/main/view/screens/terms_and_conditions_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows official legal document destinations in Arabic', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: TermsAndConditionsScreen()),
    );

    expect(find.text('الشروط والخصوصية'), findsOneWidget);
    expect(find.text('المستندات القانونية الرسمية'), findsOneWidget);
    expect(find.text('الشروط والأحكام'), findsOneWidget);
    expect(find.text('سياسة الخصوصية'), findsOneWidget);
  });
}
