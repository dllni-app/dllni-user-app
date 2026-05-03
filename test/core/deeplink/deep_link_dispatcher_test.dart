import 'package:dllni_user_app/core/app_config.dart';
import 'package:dllni_user_app/core/deeplink/deep_link_dispatcher.dart';
import 'package:dllni_user_app/core/deeplink/deep_link_models.dart';
import 'package:dllni_user_app/features/profile/view/screens/group_order_followup_screen.dart';
import 'package:dllni_user_app/features/profile/view/screens/vote_followup_screen.dart';
import 'package:dllni_user_app/features/rs_discover/view/screens/rs_product_details_screen.dart';
import 'package:dllni_user_app/features/rs_discover/view/screens/rs_store_details_screen.dart';
import 'package:dllni_user_app/features/sm_stores/view/screens/sm_product_details_screen.dart';
import 'package:dllni_user_app/features/sm_stores/view/screens/sm_store_details_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final host = AppConfig.deepLinkCanonicalHost;

  test('dispatches supermarket product to /product', () {
    final r = DeepLinkResolveResult(
      type: 'product',
      id: 9,
      slug: null,
      status: DeepLinkResolveStatus.ok,
      requiresAuth: false,
      target: 'supermarket',
    );
    final t = DeepLinkDispatcher.dispatch(r);
    expect(t?.routeName, '/product');
    expect(t?.arguments, isA<SmProductDetailsScreenArgs>());
    expect((t!.arguments! as SmProductDetailsScreenArgs).productId, 9);
  });

  test('dispatches restaurant product to /rs_product', () {
    final r = DeepLinkResolveResult(
      type: 'product',
      id: 9,
      slug: null,
      status: DeepLinkResolveStatus.ok,
      requiresAuth: false,
      target: 'restaurant',
    );
    final t = DeepLinkDispatcher.dispatch(r);
    expect(t?.routeName, '/rs_product');
    expect(t?.arguments, isA<ProductDetailsScreenParams>());
  });

  test('dispatches store', () {
    final r = DeepLinkResolveResult(
      type: 'store',
      id: 4,
      slug: null,
      status: DeepLinkResolveStatus.ok,
      requiresAuth: false,
    );
    final t = DeepLinkDispatcher.dispatch(r);
    expect(t?.routeName, '/store');
    expect((t!.arguments! as SmStoreDetailsScreenArgs).storeId, 4);
  });

  test('dispatches vote', () {
    final r = DeepLinkResolveResult(
      type: 'vote',
      id: 3,
      slug: null,
      status: DeepLinkResolveStatus.ok,
      requiresAuth: false,
    );
    final t = DeepLinkDispatcher.dispatch(r);
    expect(t?.routeName, '/votefollowup');
    expect((t!.arguments! as VoteFollowupScreenParams).voteId, 3);
  });

  test('dispatches group-order', () {
    final r = DeepLinkResolveResult(
      type: 'group-order',
      id: 100,
      slug: 'abc',
      status: DeepLinkResolveStatus.ok,
      requiresAuth: true,
    );
    final t = DeepLinkDispatcher.dispatch(r);
    expect(t?.routeName, '/group-order/followup');
    expect((t!.arguments! as GroupOrderFollowupScreenParams).groupOrderId, 100);
  });

  test('dispatches restaurant', () {
    final r = DeepLinkResolveResult(
      type: 'restaurant',
      id: 7,
      slug: 'slug',
      status: DeepLinkResolveStatus.ok,
      requiresAuth: false,
    );
    final t = DeepLinkDispatcher.dispatch(r);
    expect(t?.routeName, '/rs_store');
    expect(t?.arguments, isA<StoreDetailsScreenParams>());
  });

  test('returns null when status is not ok', () {
    final r = DeepLinkResolveResult(
      type: 'product',
      id: 1,
      slug: null,
      status: DeepLinkResolveStatus.notFound,
      requiresAuth: false,
    );
    expect(DeepLinkDispatcher.dispatch(r), isNull);
  });

  test('dispatchFromCanonicalUri parses canonical restaurant path', () {
    final u = Uri.parse('https://$host/restaurant/1');
    final t = DeepLinkDispatcher.dispatchFromCanonicalUri(u);
    expect(t?.routeName, '/rs_store');
    expect((t!.arguments! as StoreDetailsScreenParams).restaurantId, 1);
  });

  test('dispatchFromCanonicalUri parses canonical product path', () {
    final u = Uri.parse('https://$host/product/42');
    final t = DeepLinkDispatcher.dispatchFromCanonicalUri(u);
    expect(t?.routeName, '/product');
    expect((t!.arguments! as SmProductDetailsScreenArgs).productId, 42);
  });

  test('dispatchFromCanonicalUri parses canonical store path', () {
    final u = Uri.parse('https://$host/store/3');
    final t = DeepLinkDispatcher.dispatchFromCanonicalUri(u);
    expect(t?.routeName, '/store');
    expect((t!.arguments! as SmStoreDetailsScreenArgs).storeId, 3);
  });

  test('dispatchFromCanonicalUri parses canonical vote path', () {
    final u = Uri.parse('https://$host/vote/9');
    final t = DeepLinkDispatcher.dispatchFromCanonicalUri(u);
    expect(t?.routeName, '/votefollowup');
    expect((t!.arguments! as VoteFollowupScreenParams).voteId, 9);
  });

  test('dispatchFromCanonicalUri parses canonical group-order path', () {
    final u = Uri.parse('https://$host/group-order/100');
    final t = DeepLinkDispatcher.dispatchFromCanonicalUri(u);
    expect(t?.routeName, '/group-order/followup');
    expect((t!.arguments! as GroupOrderFollowupScreenParams).groupOrderId, 100);
  });

  test(
    'dispatchFromCanonicalUri parses API compatibility supermarket product path',
    () {
      final u = Uri.parse('https://$host/api/v1/user/supermarket/products/42');
      final t = DeepLinkDispatcher.dispatchFromCanonicalUri(u);
      expect(t?.routeName, '/product');
      expect((t!.arguments! as SmProductDetailsScreenArgs).productId, 42);
    },
  );

  test('dispatchFromCanonicalUri parses open endpoint path', () {
    final u = Uri.parse('https://$host/api/v1/deep-links/store/6');
    final t = DeepLinkDispatcher.dispatchFromCanonicalUri(u);
    expect(t?.routeName, '/store');
    expect((t!.arguments! as SmStoreDetailsScreenArgs).storeId, 6);
  });

  test('dispatchFromCanonicalUri returns null for short link', () {
    final u = Uri.parse('https://$host/s/abc');
    expect(DeepLinkDispatcher.dispatchFromCanonicalUri(u), isNull);
  });
}
