/// Resolver business status (API Contract V1 — returned in JSON body on HTTP 200).
enum DeepLinkResolveStatus {
  ok,
  notFound,
  forbidden,
  expired,
  unknown,
}

DeepLinkResolveStatus deepLinkResolveStatusFromString(String? raw) {
  switch ((raw ?? '').trim().toLowerCase()) {
    case 'ok':
      return DeepLinkResolveStatus.ok;
    case 'not_found':
      return DeepLinkResolveStatus.notFound;
    case 'forbidden':
      return DeepLinkResolveStatus.forbidden;
    case 'expired':
      return DeepLinkResolveStatus.expired;
    default:
      return DeepLinkResolveStatus.unknown;
  }
}

/// Normalized response from `POST /api/v1/deep-links/resolve`.
///
/// Canonical HTTPS URLs shared by the app use the same path shape as user API routes
/// (e.g. `/api/v1/user/restaurants/{id}`). The resolver should accept those URLs in
/// [canonicalUrl] / request body `url` and return [type] / [target] consistent with
/// [DeepLinkDispatcher.dispatch].
class DeepLinkResolveResult {
  const DeepLinkResolveResult({
    required this.type,
    required this.status,
    required this.requiresAuth,
    this.id,
    this.slug,
    this.canonicalUrl,
    this.fallbackUrl,
    this.target,
    this.raw,
  });

  final String type;
  final int? id;
  final String? slug;
  final DeepLinkResolveStatus status;
  final bool requiresAuth;
  final String? canonicalUrl;
  final String? fallbackUrl;

  /// When present, refines navigation (e.g. supermarket vs restaurant product).
  final String? target;

  final Map<String, dynamic>? raw;

  factory DeepLinkResolveResult.fromJson(Map<String, dynamic> json) {
    final idVal = json['id'];
    int? id;
    if (idVal is int) {
      id = idVal;
    } else if (idVal is num) {
      id = idVal.toInt();
    } else if (idVal is String) {
      id = int.tryParse(idVal.trim());
    }

    final slugVal = json['slug'];
    final slug = slugVal == null ? null : slugVal.toString();

    final targetVal = json['target'];
    final target = targetVal == null ? null : targetVal.toString();

    final requiresAuth = _readBool(json, 'requires_auth') ?? _readBool(json, 'requiresAuth') ?? false;

    final canonical = json['canonical_url'] ?? json['canonicalUrl'];
    final fallback = json['fallback_url'] ?? json['fallbackUrl'];

    final typeVal = json['type'];
    final type = typeVal == null ? '' : typeVal.toString().trim();

    final statusRaw = json['status'];
    final statusStr = statusRaw == null ? null : statusRaw.toString();

    return DeepLinkResolveResult(
      type: type,
      id: id,
      slug: slug,
      status: deepLinkResolveStatusFromString(statusStr),
      requiresAuth: requiresAuth,
      canonicalUrl: canonical == null ? null : canonical.toString(),
      fallbackUrl: fallback == null ? null : fallback.toString(),
      target: target,
      raw: json,
    );
  }

  static bool? _readBool(Map<String, dynamic> json, String key) {
    final v = json[key];
    if (v is bool) return v;
    if (v is String) {
      final s = v.toLowerCase();
      if (s == 'true' || s == '1') return true;
      if (s == 'false' || s == '0') return false;
    }
    if (v is num) return v != 0;
    return null;
  }
}

/// Result of mapping resolver output to an app named route.
class DeepLinkDispatchTarget {
  const DeepLinkDispatchTarget({required this.routeName, this.arguments});

  final String routeName;
  final Object? arguments;
}
