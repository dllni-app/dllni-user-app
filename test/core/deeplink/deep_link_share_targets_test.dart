import 'package:dllni_user_app/core/app_config.dart';
import 'package:dllni_user_app/core/deeplink/deep_link_share_targets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final base =
      '${AppConfig.deepLinkCanonicalScheme}://${AppConfig.deepLinkCanonicalHost}';

  test('productUrl', () {
    expect(productUrl(42), '$base/product/42');
  });

  test('restaurantProductUrl legacy alias', () {
    expect(restaurantProductUrl(42), '$base/product/42');
  });

  test('restaurantUrl', () {
    expect(restaurantUrl(7), '$base/restaurant/7');
  });

  test('storeUrl', () {
    expect(storeUrl(3), '$base/store/3');
  });

  test('supermarketStoreUrl legacy alias', () {
    expect(supermarketStoreUrl(3), '$base/store/3');
  });

  test('voteUrl', () {
    expect(voteUrl(99), '$base/vote/99');
  });

  test('groupOrderUrl prefers shareToken', () {
    expect(
      groupOrderUrl(id: 1, shareToken: 'abc def'),
      '$base/group-order/${Uri.encodeComponent('abc def')}',
    );
  });

  test('groupOrderUrl falls back to id', () {
    expect(groupOrderUrl(id: 5, shareToken: null), '$base/group-order/5');
    expect(groupOrderUrl(id: 5, shareToken: ''), '$base/group-order/5');
  });

  test('deepLinkBase', () {
    expect(deepLinkBase(), base);
  });

  test('deepLinkUserApiRoot compatibility alias', () {
    expect(deepLinkUserApiRoot(), base);
  });
}
