import 'package:dllni_user_app/features/home/view/widgets/home_offer_carousel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('empty offers show a static, correctly sized discovery banner', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(width: 360, child: HomeOfferCarousel(offers: [])),
        ),
      ),
    );

    expect(find.text('كل اللي تحتاجه، بمكان واحد'), findsOneWidget);
    expect(find.byType(PageView), findsNothing);
    final banner = tester.getSize(find.byType(ClipRRect).first);
    expect(banner.height, inInclusiveRange(150, 204));
    expect(banner.width, 360);
  });
}
