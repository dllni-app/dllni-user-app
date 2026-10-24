import 'package:dllni_user_app/features/sm_home/view/widgets/nearby_stores_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('empty supermarket area explains absence and offers browsing', (
    tester,
  ) async {
    var browsePressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NearbyStoresEmptyState(onBrowse: () => browsePressed = true),
        ),
      ),
    );

    expect(find.text('لا توجد متاجر قريبة منك حالياً'), findsOneWidget);
    expect(find.text('تصفح جميع المتاجر'), findsOneWidget);
    await tester.tap(find.text('تصفح جميع المتاجر'));
    expect(browsePressed, isTrue);
  });

  testWidgets(
    'standalone home route has a safe empty state without tab callback',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: NearbyStoresEmptyState())),
      );
      expect(find.text('لا توجد متاجر قريبة منك حالياً'), findsOneWidget);
      expect(find.text('تصفح جميع المتاجر'), findsNothing);
    },
  );
}
