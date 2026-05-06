import 'package:dllni_user_app/core/app_config.dart';
import 'package:dllni_user_app/core/deeplink/deep_link_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final host = AppConfig.deepLinkCanonicalHost;

  group('DeepLinkParser.isSupportedDeepLink', () {
    test('accepts canonical product path', () {
      final u = Uri.parse('https://$host/product/12');
      expect(DeepLinkParser.isSupportedDeepLink(u), isTrue);
    });

    test('accepts canonical restaurant path', () {
      final u = Uri.parse('https://$host/restaurant/7');
      expect(DeepLinkParser.isSupportedDeepLink(u), isTrue);
    });

    test('accepts canonical store path', () {
      final u = Uri.parse('https://$host/store/3');
      expect(DeepLinkParser.isSupportedDeepLink(u), isTrue);
    });

    test('accepts canonical vote path', () {
      final u = Uri.parse('https://$host/vote/9');
      expect(DeepLinkParser.isSupportedDeepLink(u), isTrue);
    });

    test('accepts canonical group-order path', () {
      final u = Uri.parse('https://$host/group-order/5');
      expect(DeepLinkParser.isSupportedDeepLink(u), isTrue);
    });

    test('accepts open API endpoint path', () {
      final u = Uri.parse('https://$host/api/v1/deep-links/product/11');
      expect(DeepLinkParser.isSupportedDeepLink(u), isTrue);
      final n = DeepLinkParser.normalizeOpenApiPathIfNeeded(u);
      expect(n.path, '/product/11');
    });

    test('accepts landing open path with deep_link query', () {
      final u = Uri.parse(
        'https://$host/open?deep_link=https%3A%2F%2F$host%2Fproduct%2F3',
      );
      expect(DeepLinkParser.isSupportedDeepLink(u), isTrue);
      final extracted = DeepLinkParser.extractDeepLinkFromLanding(u);
      expect(extracted?.toString(), 'https://$host/product/3');
    });

    test('accepts API compatibility paths', () {
      expect(
        DeepLinkParser.isSupportedDeepLink(
          Uri.parse('https://$host/api/v1/user/restaurants/12'),
        ),
        isTrue,
      );
      expect(
        DeepLinkParser.isSupportedDeepLink(
          Uri.parse('https://$host/api/v1/user/supermarket/products/1'),
        ),
        isTrue,
      );
      expect(
        DeepLinkParser.isSupportedDeepLink(
          Uri.parse('https://$host/api/v1/user/products/2'),
        ),
        isTrue,
      );
    });

    test('accepts short link for backward compatibility', () {
      final u = Uri.parse('https://$host/s/abc123');
      expect(DeepLinkParser.isSupportedDeepLink(u), isTrue);
    });

    test('accepts www host and normalizes', () {
      final u = Uri.parse('https://www.$host/product/7');
      expect(DeepLinkParser.isSupportedDeepLink(u), isTrue);
      final n = DeepLinkParser.normalizeHostIfNeeded(u);
      expect(n.host, host);
      expect(n.path, '/product/7');
    });

    test('rejects wrong host', () {
      final u = Uri.parse('https://evil.com/product/12');
      expect(DeepLinkParser.isSupportedDeepLink(u), isFalse);
    });

    test('rejects unknown path', () {
      final u = Uri.parse('https://$host/unknown/12');
      expect(DeepLinkParser.isSupportedDeepLink(u), isFalse);
    });
  });
}
