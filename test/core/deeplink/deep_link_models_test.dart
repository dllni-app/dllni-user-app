import 'package:dllni_user_app/core/app_config.dart';
import 'package:dllni_user_app/core/deeplink/deep_link_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DeepLinkResolveResult.fromJson parses snake_case', () {
    final base =
        '${AppConfig.deepLinkCanonicalScheme}://${AppConfig.deepLinkCanonicalHost}';
    final r = DeepLinkResolveResult.fromJson(<String, dynamic>{
      'type': 'product',
      'id': 5,
      'slug': 'x',
      'status': 'ok',
      'requires_auth': false,
      'canonical_url': '$base/product/5',
      'fallback_url': '$base/open',
      'target': 'supermarket',
      'query': <String, dynamic>{'source': 'whatsapp'},
    });
    expect(r.type, 'product');
    expect(r.id, 5);
    expect(r.status, DeepLinkResolveStatus.ok);
    expect(r.requiresAuth, isFalse);
    expect(r.target, 'supermarket');
    expect(r.query?['source'], 'whatsapp');
  });

  test('deepLinkResolveStatusFromString maps known values', () {
    expect(
      deepLinkResolveStatusFromString('not_found'),
      DeepLinkResolveStatus.notFound,
    );
    expect(
      deepLinkResolveStatusFromString('forbidden'),
      DeepLinkResolveStatus.forbidden,
    );
  });
}
