import 'package:dllni_user_app/core/deeplink/deep_link_models.dart';
import 'package:dllni_user_app/core/deeplink/deep_link_parser.dart';
import 'package:dllni_user_app/features/profile/view/screens/group_order_followup_screen.dart';
import 'package:dllni_user_app/features/profile/view/screens/vote_followup_screen.dart';
import 'package:dllni_user_app/features/rs_discover/view/models/product_preview_data.dart';
import 'package:dllni_user_app/features/rs_discover/view/models/restaurant_preview_data.dart';
import 'package:dllni_user_app/features/rs_discover/view/screens/rs_product_details_screen.dart';
import 'package:dllni_user_app/features/rs_discover/view/screens/rs_store_details_screen.dart';
import 'package:dllni_user_app/features/sm_stores/view/screens/sm_product_details_screen.dart';
import 'package:dllni_user_app/features/sm_stores/view/screens/sm_store_details_screen.dart';

/// Maps resolver [DeepLinkResolveResult] to existing [GeneratedAppRoutes] names and args.
class DeepLinkDispatcher {
  DeepLinkDispatcher._();

  static DeepLinkResolveResult _synthetic({
    required String type,
    required int id,
    String? target,
  }) {
    return DeepLinkResolveResult(
      type: type,
      status: DeepLinkResolveStatus.ok,
      requiresAuth: false,
      id: id,
      slug: null,
      canonicalUrl: null,
      fallbackUrl: null,
      target: target,
      raw: null,
    );
  }

  static DeepLinkDispatchTarget? dispatch(DeepLinkResolveResult resolved) {
    if (resolved.status != DeepLinkResolveStatus.ok) {
      return null;
    }

    final type = resolved.type.trim().toLowerCase();

    switch (type) {
      case 'product':
        return _dispatchProduct(resolved);
      case 'restaurant':
        return _dispatchRestaurant(resolved);
      case 'store':
        return _dispatchStore(resolved);
      case 'vote':
        return _dispatchVote(resolved);
      case 'group-order':
        return _dispatchGroupOrder(resolved);
      default:
        return null;
    }
  }

  /// When the resolver API is down, returns 404, or [not_found], map canonical paths
  /// to the same routes as [dispatch]. Short links (`/s/...`) are not handled here.
  static DeepLinkDispatchTarget? dispatchFromCanonicalUri(Uri uri) {
    if (!DeepLinkParser.isSupportedDeepLink(uri)) {
      return null;
    }
    final normalized = DeepLinkParser.normalizeOpenApiPathIfNeeded(uri);
    final segments = normalized.pathSegments
        .where((String s) => s.isNotEmpty)
        .toList();
    if (segments.isEmpty) {
      return null;
    }
    if (segments.length >= 5 &&
        segments[0].toLowerCase() == 'api' &&
        segments[1] == 'v1' &&
        segments[2] == 'user') {
      return _dispatchFromApiUserSegments(segments);
    }
    return _dispatchFromCanonicalSegments(segments, normalized);
  }

  static DeepLinkDispatchTarget? _dispatchFromApiUserSegments(
    List<String> segments,
  ) {
    if (segments.length >= 6 &&
        segments[3] == 'restaurants' &&
        segments[4] == 'votes') {
      final id = int.tryParse(segments[5]);
      if (id == null || id <= 0) {
        return null;
      }
      return _dispatchVote(_synthetic(type: 'vote', id: id));
    }
    if (segments.length >= 6 &&
        segments[3] == 'restaurants' &&
        segments[4] == 'group-orders') {
      final raw = segments[5];
      final id = int.tryParse(raw);
      if (id == null || id <= 0) {
        return null;
      }
      return _dispatchGroupOrder(_synthetic(type: 'group-order', id: id));
    }
    if (segments.length >= 5 && segments[3] == 'restaurants') {
      final id = int.tryParse(segments[4]);
      if (id == null || id <= 0) {
        return null;
      }
      return _dispatchRestaurant(_synthetic(type: 'restaurant', id: id));
    }
    if (segments.length >= 6 &&
        segments[3] == 'supermarket' &&
        segments[4] == 'products') {
      final id = int.tryParse(segments[5]);
      if (id == null || id <= 0) {
        return null;
      }
      return _dispatchProduct(
        _synthetic(type: 'product', id: id, target: 'supermarket'),
      );
    }
    if (segments.length >= 6 &&
        segments[3] == 'supermarket' &&
        segments[4] == 'stores') {
      final id = int.tryParse(segments[5]);
      if (id == null || id <= 0) {
        return null;
      }
      return DeepLinkDispatchTarget(
        routeName: '/store',
        arguments: SmStoreDetailsScreenArgs(storeId: id),
      );
    }
    if (segments.length >= 5 && segments[3] == 'products') {
      final id = int.tryParse(segments[4]);
      if (id == null || id <= 0) {
        return null;
      }
      return _dispatchProduct(
        _synthetic(type: 'product', id: id, target: 'restaurant'),
      );
    }
    return null;
  }

  static DeepLinkDispatchTarget? _dispatchFromCanonicalSegments(
    List<String> segments,
    Uri uri,
  ) {
    if (segments.length < 2) {
      return null;
    }
    final first = segments.first.toLowerCase();
    if (first == 's') {
      return null;
    }
    final rawSecond = segments[1];
    final id = int.tryParse(rawSecond);
    if (id == null || id <= 0) {
      return null;
    }

    final synthetic = DeepLinkResolveResult(
      type: first == 'group-order' ? 'group-order' : first,
      status: DeepLinkResolveStatus.ok,
      requiresAuth: false,
      id: id,
      slug: null,
      canonicalUrl: uri.toString(),
      fallbackUrl: null,
      target: null,
      raw: null,
    );

    switch (first) {
      case 'product':
        return _dispatchProduct(synthetic);
      case 'restaurant':
        return _dispatchRestaurant(synthetic);
      case 'store':
        return _dispatchStore(synthetic);
      case 'vote':
        return _dispatchVote(synthetic);
      case 'group-order':
        return _dispatchGroupOrder(synthetic);
      default:
        return null;
    }
  }

  static DeepLinkDispatchTarget? _dispatchProduct(DeepLinkResolveResult r) {
    final productId = r.id;
    if (productId == null || productId <= 0) {
      return null;
    }

    final target = (r.target ?? '').trim().toLowerCase();
    final isRestaurant = target == 'restaurant' || target == 'rs';

    if (isRestaurant) {
      final preview = ProductPreviewData(
        productId: productId,
        name: '',
        restaurantName: '',
        description: '',
        displayPrice: null,
        originalPrice: null,
      );
      return DeepLinkDispatchTarget(
        routeName: '/rs_product',
        arguments: ProductDetailsScreenParams(product: preview),
      );
    }

    return DeepLinkDispatchTarget(
      routeName: '/product',
      arguments: SmProductDetailsScreenArgs(productId: productId),
    );
  }

  static DeepLinkDispatchTarget? _dispatchRestaurant(DeepLinkResolveResult r) {
    final restaurantId = r.id;
    if (restaurantId == null || restaurantId <= 0) {
      return null;
    }

    final label = (r.slug ?? '').trim();
    final preview = RestaurantPreviewData(
      restaurantId: restaurantId,
      name: label.isNotEmpty ? label : 'مطعم',
      description: '',
    );

    return DeepLinkDispatchTarget(
      routeName: '/rs_store',
      arguments: StoreDetailsScreenParams(
        restaurantId: restaurantId,
        preview: preview,
      ),
    );
  }

  static DeepLinkDispatchTarget? _dispatchStore(DeepLinkResolveResult r) {
    final storeId = r.id;
    if (storeId == null || storeId <= 0) {
      return null;
    }

    return DeepLinkDispatchTarget(
      routeName: '/store',
      arguments: SmStoreDetailsScreenArgs(storeId: storeId),
    );
  }

  static DeepLinkDispatchTarget? _dispatchVote(DeepLinkResolveResult r) {
    final voteId = r.id;
    if (voteId == null || voteId <= 0) {
      return null;
    }

    return DeepLinkDispatchTarget(
      routeName: '/votefollowup',
      arguments: VoteFollowupScreenParams(voteId: voteId),
    );
  }

  static DeepLinkDispatchTarget? _dispatchGroupOrder(DeepLinkResolveResult r) {
    final groupOrderId = r.id;
    if (groupOrderId == null || groupOrderId <= 0) {
      return null;
    }

    final rawShareToken = r.slug?.trim();
    final shareToken = (rawShareToken == null || rawShareToken.isEmpty)
        ? null
        : rawShareToken;

    return DeepLinkDispatchTarget(
      routeName: '/group-order/followup',
      arguments: GroupOrderFollowupScreenParams(
        groupOrderId: groupOrderId,
        shareToken: shareToken,
      ),
    );
  }
}
