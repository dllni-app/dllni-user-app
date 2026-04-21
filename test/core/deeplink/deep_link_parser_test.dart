import 'package:dllni_user_app/core/deeplink/deep_link_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeepLinkParser.isSupportedDeepLink', () {
    test('accepts API restaurant path', () {
      final u = Uri.parse('https://dllni.mustafafares.com/api/v1/user/restaurants/12');
      expect(DeepLinkParser.isSupportedDeepLink(u), isTrue);
    });

    test('accepts API product paths', () {
      expect(
        DeepLinkParser.isSupportedDeepLink(Uri.parse('https://dllni.mustafafares.com/api/v1/user/supermarket/products/1')),
        isTrue,
      );
      expect(
        DeepLinkParser.isSupportedDeepLink(Uri.parse('https://dllni.mustafafares.com/api/v1/user/products/2')),
        isTrue,
      );
    });

    test('accepts API supermarket store path', () {
      final u = Uri.parse('https://dllni.mustafafares.com/api/v1/user/supermarket/stores/3');
      expect(DeepLinkParser.isSupportedDeepLink(u), isTrue);
    });

    test('accepts API vote path', () {
      final u = Uri.parse('https://dllni.mustafafares.com/api/v1/user/restaurants/votes/9');
      expect(DeepLinkParser.isSupportedDeepLink(u), isTrue);
    });

    test('accepts API group-order path', () {
      final u = Uri.parse('https://dllni.mustafafares.com/api/v1/user/restaurants/group-orders/5');
      expect(DeepLinkParser.isSupportedDeepLink(u), isTrue);
    });

    test('accepts legacy product path', () {
      final u = Uri.parse('https://dllni.mustafafares.com/product/12');
      expect(DeepLinkParser.isSupportedDeepLink(u), isTrue);
    });

    test('accepts product path with www host', () {
      final u = Uri.parse('https://www.dllni.mustafafares.com/api/v1/user/products/7');
      expect(DeepLinkParser.isSupportedDeepLink(u), isTrue);
      final n = DeepLinkParser.normalizeHostIfNeeded(u);
      expect(n.host, 'dllni.mustafafares.com');
      expect(n.path, '/api/v1/user/products/7');
    });

    test('accepts short link', () {
      final u = Uri.parse('https://dllni.mustafafares.com/s/abc123');
      expect(DeepLinkParser.isSupportedDeepLink(u), isTrue);
    });

    test('rejects wrong host', () {
      final u = Uri.parse('https://evil.com/api/v1/user/restaurants/12');
      expect(DeepLinkParser.isSupportedDeepLink(u), isFalse);
    });

    test('rejects unknown path', () {
      final u = Uri.parse('https://dllni.mustafafares.com/unknown/12');
      expect(DeepLinkParser.isSupportedDeepLink(u), isFalse);
    });
  });
}
