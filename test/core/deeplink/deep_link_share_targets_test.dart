import 'package:dllni_user_app/core/deeplink/deep_link_share_targets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const base = 'https://dllni.mustafafares.com';
  const api = '$base/api/v1/user';

  test('supermarketProductUrl', () {
    expect(supermarketProductUrl(42), '$api/supermarket/products/42');
  });

  test('restaurantProductUrl', () {
    expect(restaurantProductUrl(42), '$api/products/42');
  });

  test('restaurantUrl', () {
    expect(restaurantUrl(7), '$api/restaurants/7');
  });

  test('supermarketStoreUrl', () {
    expect(supermarketStoreUrl(3), '$api/supermarket/stores/3');
  });

  test('voteUrl', () {
    expect(voteUrl(99), '$api/restaurants/votes/99');
  });

  test('groupOrderUrl prefers shareToken', () {
    expect(
      groupOrderUrl(id: 1, shareToken: 'abc def'),
      '$api/restaurants/group-orders/${Uri.encodeComponent('abc def')}',
    );
  });

  test('groupOrderUrl falls back to id', () {
    expect(groupOrderUrl(id: 5, shareToken: null), '$api/restaurants/group-orders/5');
    expect(groupOrderUrl(id: 5, shareToken: ''), '$api/restaurants/group-orders/5');
  });

  test('deepLinkBase', () {
    expect(deepLinkBase(), base);
  });

  test('deepLinkUserApiRoot', () {
    expect(deepLinkUserApiRoot(), api);
  });
}
