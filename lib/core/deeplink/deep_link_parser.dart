import 'package:dllni_user_app/core/app_config.dart';

/// Validates incoming URIs for the deep-link host and known path prefixes.
class DeepLinkParser {
  DeepLinkParser._();

  static const Set<String> _canonicalTypes = <String>{
    'product',
    'restaurant',
    'store',
    'vote',
    'group-order',
  };

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

    if (_isOpenLandingPath(uri, segments)) {
      return true;
    }

    final first = segments.first.toLowerCase();

    // Backward compatibility with short-code web flows (`/s/{code}`).
    if (first == 's' && segments.length >= 2) {
      return true;
    }

    if (_isOpenApiPath(segments)) {
      return true;
    }

    if (segments.length >= 5 &&
        first == 'api' &&
        segments[1] == 'v1' &&
        segments[2] == 'user') {
      return _isSupportedApiUserPath(segments);
    }

    return segments.length >= 2 && _canonicalTypes.contains(first);
  }

  /// Converts `/api/v1/deep-links/{type}/{identifier}` into canonical `/{type}/{identifier}`
  /// so resolver + local dispatcher can share one shape.
  static Uri normalizeOpenApiPathIfNeeded(Uri uri) {
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (!_isOpenApiPath(segments)) {
      return uri;
    }

    final type = segments[3];
    final identifier = segments[4];
    return uri.replace(pathSegments: <String>[type, identifier]);
  }

  /// Extracts `deep_link` from web landing `/open?deep_link=...` when present.
  static Uri? extractDeepLinkFromLanding(Uri uri) {
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (!_isOpenLandingPath(uri, segments)) {
      return null;
    }
    final raw = uri.queryParameters['deep_link']?.trim();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return Uri.tryParse(raw);
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

  static bool _isOpenApiPath(List<String> segments) {
    if (segments.length < 5) {
      return false;
    }
    return segments[0] == 'api' &&
        segments[1] == 'v1' &&
        segments[2] == 'deep-links' &&
        _canonicalTypes.contains(segments[3]) &&
        segments[4].trim().isNotEmpty;
  }

  static bool _isOpenLandingPath(Uri uri, List<String> segments) {
    if (segments.length != 1 || segments.first != 'open') {
      return false;
    }
    return (uri.queryParameters['deep_link'] ?? '').trim().isNotEmpty;
  }
}
