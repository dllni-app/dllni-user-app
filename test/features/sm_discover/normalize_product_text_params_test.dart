import 'package:dllni_user_app/features/sm_discover/domain/usecases/normalize_product_text_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NormalizeProductTextParams API contract', () {
    test('restaurant smart search sends the backend resturant module', () {
      final params = NormalizeProductTextParams(
        text: 'بدي سبايسي',
        locale: 'ar',
        isSupermarket: false,
      );

      expect(params.getBody(), <String, dynamic>{
        'text': 'بدي سبايسي',
        'locale': 'ar',
        'module': 'resturant',
      });
    });

    test('restaurant meal queries such as nuggets keep restaurant scope', () {
      final params = NormalizeProductTextParams(
        text: 'بدي ناغيت',
        locale: 'ar',
        isSupermarket: false,
      );

      expect(params.getBody()['module'], 'resturant');
    });

    test('supermarket smart search keeps supermarket module', () {
      final params = NormalizeProductTextParams(
        text: 'بدي ربطة خبز',
        locale: 'ar',
        isSupermarket: true,
      );

      expect(params.getBody()['module'], 'supermarket');
    });
  });
}
