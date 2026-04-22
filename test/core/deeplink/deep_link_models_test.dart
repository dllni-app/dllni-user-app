import 'package:dllni_user_app/core/deeplink/deep_link_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DeepLinkResolveResult.fromJson parses snake_case', () {
    final r = DeepLinkResolveResult.fromJson(<String, dynamic>{
      'type': 'product',
      'id': 5,
      'slug': 'x',
      'status': 'ok',
      'requires_auth': false,
      'canonical_url': 'https://dllni.mustafafares.com/product/5',
      'fallback_url': 'https://dllni.mustafafares.com/open',
      'target': 'supermarket',
    });
    expect(r.type, 'product');
    expect(r.id, 5);
    expect(r.status, DeepLinkResolveStatus.ok);
    expect(r.requiresAuth, isFalse);
    expect(r.target, 'supermarket');
  });

  test('deepLinkResolveStatusFromString maps known values', () {
    expect(deepLinkResolveStatusFromString('not_found'), DeepLinkResolveStatus.notFound);
    expect(deepLinkResolveStatusFromString('forbidden'), DeepLinkResolveStatus.forbidden);
  });
}
