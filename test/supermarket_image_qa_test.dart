import 'package:dllni_user_app/features/sm_stores/data/models/sm_store_product_summary.dart';
import 'package:dllni_user_app/features/sm_stores/data/models/supermarket_image_quality.dart';
import 'package:dllni_user_app/features/sm_stores/view/widgets/unavailable_product_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('recognizes the deployed 1x1 PNG placeholder metadata', () {
    expect(isTinySupermarketPlaceholder('68 B'), isTrue);
    expect(isTinySupermarketPlaceholder('128 B'), isTrue);
    expect(isTinySupermarketPlaceholder('4 KB'), isFalse);
    expect(isTinySupermarketPlaceholder('1024 B'), isFalse);
    expect(isTinySupermarketPlaceholder(null), isFalse);
  });

  test('retains media size from store product response', () {
    final item = SmStoreProductSummary.fromJson({
      'id': 71,
      'name': 'مياه معدنية',
      'imageUrl': 'https://example.test/empty.png',
      'image': {
        'id': 392,
        'url': 'https://example.test/empty.png',
        'size': '68 B',
      },
    });
    expect(item.image?.size, '68 B');
    expect(isTinySupermarketPlaceholder(item.image?.size), isTrue);
    expect((item.toJson()['image'] as Map)['size'], '68 B');
  });

  testWidgets('unavailable image conveys missing photo accessibly', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: UnavailableProductImage(height: 120, width: 260)),
      ),
    );
    expect(find.text('صورة المنتج غير متوفرة'), findsOneWidget);
    expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
  });
}
