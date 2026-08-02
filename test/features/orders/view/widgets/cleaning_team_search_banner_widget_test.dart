import 'package:dllni_user_app/features/orders/view/widgets/cleaning_team_search_banner_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows preferred-worker fallback alert message', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(body: CleaningPreferredWorkerFallbackBannerWidget()),
        ),
      ),
    );

    expect(
      find.text(
        'رفض العامل المخصص الطلب. تم تحويل طلبك إلى طلب عام ونبحث الآن عن عامل بديل.',
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
  });
}
