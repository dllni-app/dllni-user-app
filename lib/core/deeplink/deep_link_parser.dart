import 'package:dllni_user_app/core/app_config.dart';

/// Validates incoming URIs for the deep-link host and known path prefixes.
class DeepLinkParser {
  DeepLinkParser._();

  /// Apex host only (no `www.`), for comparison with [AppConfig.deepLinkCanonicalHost].
  static String canonicalHost(Uri uri) {
    var h = uri.host.toLowerCase();
    if (h.startsWith('www.')) {
      h = h.substring(4);
    }
    return h;
  }

  /// Ensures [Uri.host] is exactly [AppConfig.deepLinkCanonicalHost] when the link targets
  /// this app (handles `www.dllni...` vs apex).
  static Uri normalizeHostIfNeeded(Uri uri) {
    if (canonicalHost(uri) != AppConfig.deepLinkCanonicalHost) {
      return uri;
    }
    if (uri.host.toLowerCase() == AppConfig.deepLinkCanonicalHost) {
      return uri;
    }
    return uri.replace(host: AppConfig.deepLinkCanonicalHost);
  }

  static bool isSupportedDeepLink(Uri uri) {
    if (canonicalHost(uri) != AppConfig.deepLinkCanonicalHost) {
      return false;
    }
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) {
      return false;
    }
    final first = segments.first.toLowerCase();
    if (first == 's' && segments.length >= 2) {
      return true;
    }
    if (segments.length >= 5 && first == 'api' && segments[1] == 'v1' && segments[2] == 'user') {
      return _isSupportedApiUserPath(segments);
    }
    if (segments.length < 2) {
      return false;
    }
    switch (first) {
      case 'product':
      case 'restaurant':
      case 'vote':
      case 'group-order':
        return true;
      default:
        return false;
    }
  }

  /// `/api/v1/user/...` paths aligned with REST endpoints (see [deep_link_share_targets.dart]).
  static bool _isSupportedApiUserPath(List<String> segments) {
    if (segments.length < 5) {
      return false;
    }
    final a = segments[3];
    if (a == 'restaurants') {
      if (segments.length >= 6) {
        if (segments[4] == 'votes' || segments[4] == 'group-orders') {
          return true;
        }
      }
      if (segments.length >= 5 && int.tryParse(segments[4]) != null) {
        return true;
      }
      return false;
    }
    if (a == 'supermarket' && segments.length >= 6) {
      final b = segments[4];
      return b == 'products' || b == 'stores';
    }
    if (a == 'products' && segments.length >= 5) {
      return int.tryParse(segments[4]) != null;
    }
    return false;
  }
}
