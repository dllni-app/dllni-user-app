import 'package:dllni_user_app/core/widgets/rs_app_product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('keeps the order button below the product price', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: Color(0xff1E2A78),
            onPrimary: Color(0xffffffff),
            secondary: Color(0xff6C63FF),
            onSecondary: Color(0xffffffff),
            error: Color(0xffBF393D),
            onError: Color(0xffffffff),
            surface: Color(0xffF0F0F0),
            onSurface: Color(0xff000000),
            primaryContainer: Color(0xffFF7A00),
            onPrimaryContainer: Color(0xffffffff),
          ),
        ),
        home: const Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Center(
              child: SizedBox(
                height: 280,
                child: RsAppProductCard(
                  image: '',
                  title: 'باستا كاربونارا',
                  restaurant: 'Dealer Restaurant',
                  price: '110 ل.س',
                  isInCart: true,
                  productId: 1,
                  offer: null,
                  onTap: _noop,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('110 ل.س'), findsOneWidget);
    expect(find.text('تم الطلب'), findsOneWidget);

    final priceTop = tester.getTopLeft(find.text('110 ل.س')).dy;
    final buttonTop = tester.getTopLeft(find.text('تم الطلب')).dy;

    expect(buttonTop, greaterThan(priceTop));
  });
}

void _noop() {}
