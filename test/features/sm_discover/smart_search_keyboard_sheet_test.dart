import 'package:dllni_user_app/features/sm_discover/view/widgets/smart_search_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpSearchSheet(
    WidgetTester tester, {
    required double keyboardHeight,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          resizeToAvoidBottomInset: false,
          body: MediaQuery(
            data: MediaQueryData(
              size: const Size(400, 800),
              padding: const EdgeInsets.only(bottom: 20),
              viewInsets: EdgeInsets.only(bottom: keyboardHeight),
            ),
            child: const SmartSearchSheet(isSupermarket: false),
          ),
        ),
      ),
    );
  }

  testWidgets('restaurant smart search moves above the keyboard', (tester) async {
    await pumpSearchSheet(tester, keyboardHeight: 300);
    final padding = tester.widget<AnimatedPadding>(
      find.descendant(
        of: find.byType(SmartSearchSheet),
        matching: find.byType(AnimatedPadding),
      ).first,
    );
    expect(padding.padding, const EdgeInsets.only(bottom: 300));
    expect(find.text('البحث الذكي'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('restaurant smart search retains safe-area spacing when closed', (tester) async {
    await pumpSearchSheet(tester, keyboardHeight: 0);
    final padding = tester.widget<AnimatedPadding>(
      find.descendant(
        of: find.byType(SmartSearchSheet),
        matching: find.byType(AnimatedPadding),
      ).first,
    );
    expect(padding.padding, const EdgeInsets.only(bottom: 20));
  });
}
