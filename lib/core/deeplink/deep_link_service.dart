import 'dart:async';
import 'dart:io' show Platform;

import 'package:app_links/app_links.dart';
import 'package:common_package/common_package.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:injectable/injectable.dart';

import 'deep_link_dispatcher.dart';
import 'deep_link_fallback_screen.dart';
import 'deep_link_models.dart';
import 'deep_link_parser.dart';
import 'deep_link_remote_data_source.dart';

@lazySingleton
class DeepLinkService {
  DeepLinkService(this._remoteDataSource);

  final DeepLinkRemoteDataSource _remoteDataSource;

  static const String _pendingKey = 'pending_deep_link_url';

  GlobalKey<NavigatorState>? _navigatorKey;
  StreamSubscription<Uri>? _uriSub;
  final AppLinks _appLinks = AppLinks();

  String? _lastFingerprint;
  DateTime? _lastAt;
  static const Duration _dedupe = Duration(seconds: 2);

  String _platformLabel() {
    if (kIsWeb) return 'web';
    try {
      return Platform.isAndroid ? 'android' : 'ios';
    } catch (_) {
      return 'unknown';
    }
  }

  bool _hasAuthToken() {
    final t = SharedPreferencesHelper.getData(key: 'token');
    return t != null && t.toString().trim().isNotEmpty;
  }

  Future<void> init({required GlobalKey<NavigatorState> navigatorKey}) async {
    _navigatorKey = navigatorKey;

    _uriSub ??= _appLinks.uriLinkStream.listen(_onUri);

    final initial = await _appLinks.getInitialLink();
    if (initial != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        unawaited(handleIncomingUri(initial));
      });
    }
  }

  /// Stream can emit before [runApp] has mounted [MaterialApp]; defer like [getInitialLink].
  void _onUri(Uri uri) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      unawaited(handleIncomingUri(uri));
    });
  }

  bool _isDuplicate(String fingerprint) {
    final now = DateTime.now();
    if (_lastFingerprint == fingerprint &&
        _lastAt != null &&
        now.difference(_lastAt!) < _dedupe) {
      return true;
    }
    _lastFingerprint = fingerprint;
    _lastAt = now;
    return false;
  }

  Map<String, String> _trackingFromUri(Uri uri) {
    final q = uri.queryParameters;
    return <String, String>{
      if (q['source'] != null) 'source': q['source']!,
      if (q['medium'] != null) 'medium': q['medium']!,
      if (q['campaign'] != null) 'campaign': q['campaign']!,
      if (q['source'] == null && q['utm_source'] != null)
        'source': q['utm_source']!,
      if (q['medium'] == null && q['utm_medium'] != null)
        'medium': q['utm_medium']!,
      if (q['campaign'] == null && q['utm_campaign'] != null)
        'campaign': q['utm_campaign']!,
    };
  }

  int? _sharerIdFromUri(Uri uri) {
    final raw =
        uri.queryParameters['sharer_id'] ?? uri.queryParameters['sharerId'];
    if (raw == null || raw.isEmpty) return null;
    return int.tryParse(raw);
  }

  Uri _mergeTrackingQuery({required Uri base, required Uri fallback}) {
    final merged = Map<String, String>.from(base.queryParameters);
    const keys = <String>[
      'source',
      'medium',
      'campaign',
      'utm_source',
      'utm_medium',
      'utm_campaign',
      'sharer_id',
      'sharerId',
    ];

    for (final key in keys) {
      final current = merged[key]?.trim();
      if (current != null && current.isNotEmpty) {
        continue;
      }
      final v = fallback.queryParameters[key]?.trim();
      if (v != null && v.isNotEmpty) {
        merged[key] = v;
      }
    }

    return base.replace(queryParameters: merged.isEmpty ? null : merged);
  }

  Uri? _normalizeIncomingUri(Uri uri) {
    var normalized = DeepLinkParser.normalizeHostIfNeeded(uri);

    final embedded = DeepLinkParser.extractDeepLinkFromLanding(normalized);
    if (embedded != null) {
      var inner = DeepLinkParser.normalizeHostIfNeeded(embedded);
      inner = DeepLinkParser.normalizeOpenApiPathIfNeeded(inner);
      inner = _mergeTrackingQuery(base: inner, fallback: normalized);
      normalized = inner;
    } else {
      normalized = DeepLinkParser.normalizeOpenApiPathIfNeeded(normalized);
    }

    if (!DeepLinkParser.isSupportedDeepLink(normalized)) {
      return null;
    }
    return normalized;
  }

  Future<void> handleIncomingUri(Uri uri, {bool isResume = false}) async {
    final normalized = _normalizeIncomingUri(uri);
    if (normalized == null) {
      return;
    }

    final urlStr = normalized.toString();
    if (_isDuplicate('$isResume|$urlStr')) {
      return;
    }

    final tracking = _trackingFromUri(normalized);
    final sharerId = _sharerIdFromUri(normalized);
    final platform = _platformLabel();

    await _remoteDataSource.postDeepLinkEvent(
      action: 'click',
      url: urlStr,
      source: tracking['source'],
      medium: tracking['medium'],
      campaign: tracking['campaign'],
      sharerId: sharerId,
      platform: platform,
    );

    final resolved = await _remoteDataSource.resolve(urlStr);
    if (resolved != null) {
      await _remoteDataSource.postDeepLinkEvent(
        action: 'resolve',
        url: resolved.canonicalUrl ?? urlStr,
        source: tracking['source'],
        medium: tracking['medium'],
        campaign: tracking['campaign'],
        sharerId: sharerId,
        platform: platform,
      );
    }

    final pendingUrl =
        (resolved?.canonicalUrl != null &&
            resolved!.canonicalUrl!.trim().isNotEmpty)
        ? resolved.canonicalUrl!.trim()
        : urlStr;

    if (resolved != null &&
        resolved.status == DeepLinkResolveStatus.forbidden &&
        resolved.requiresAuth &&
        !_hasAuthToken()) {
      await _savePending(pendingUrl);
      _goLogin();
      return;
    }

    if (resolved != null &&
        resolved.status != DeepLinkResolveStatus.ok &&
        !(resolved.status == DeepLinkResolveStatus.forbidden &&
            resolved.requiresAuth)) {
      _pushFallback(
        fallbackUrl: resolved.fallbackUrl,
        message: _messageForStatus(resolved.status),
      );
      return;
    }

    DeepLinkDispatchTarget? apiTarget;
    if (resolved != null && resolved.status == DeepLinkResolveStatus.ok) {
      apiTarget = DeepLinkDispatcher.dispatch(resolved);
    }
    final localTarget = DeepLinkDispatcher.dispatchFromCanonicalUri(normalized);
    final target = apiTarget ?? localTarget;

    if (target == null) {
      if (resolved == null) {
        _pushFallback(
          fallbackUrl: null,
          message: 'Unable to verify deep link.',
        );
      } else {
        _pushFallback(
          fallbackUrl: resolved.fallbackUrl,
          message: _messageForStatus(resolved.status),
        );
      }
      return;
    }

    var requiresAuth = resolved?.requiresAuth == true;
    if (!requiresAuth && apiTarget == null && _routeNeedsLocalAuth(target)) {
      requiresAuth = true;
    }
    if (requiresAuth && !_hasAuthToken()) {
      await _savePending(pendingUrl);
      _goLogin();
      return;
    }

    final pushed = await _pushNamedWithRetry(
      target.routeName,
      target.arguments,
    );
    if (!pushed) {
      _pushFallback(
        fallbackUrl: resolved?.fallbackUrl,
        message: 'Unable to open deep link.',
      );
      return;
    }

    await _remoteDataSource.postDeepLinkEvent(
      action: 'open',
      url: resolved?.canonicalUrl ?? urlStr,
      source: tracking['source'],
      medium: tracking['medium'],
      campaign: tracking['campaign'],
      sharerId: sharerId,
      platform: platform,
    );
  }

  bool _routeNeedsLocalAuth(DeepLinkDispatchTarget target) {
    return target.routeName == '/votefollowup' ||
        target.routeName == '/group-order/followup';
  }

  String? _messageForStatus(DeepLinkResolveStatus st) {
    switch (st) {
      case DeepLinkResolveStatus.notFound:
        return 'The link was not found.';
      case DeepLinkResolveStatus.expired:
        return 'This link has expired.';
      case DeepLinkResolveStatus.forbidden:
        return 'You do not have access to this content.';
      default:
        return 'Unable to open this link.';
    }
  }

  Future<void> _savePending(String url) async {
    await SharedPreferencesHelper.saveData(key: _pendingKey, value: url);
  }

  void _goLogin() {
    final nav = _navigatorKey?.currentState;
    if (nav == null) return;
    nav.pushNamed('/login');
  }

  bool _pushNamed(String routeName, Object? arguments) {
    final nav = _navigatorKey?.currentState;
    if (nav == null) return false;
    try {
      nav.pushNamed(routeName, arguments: arguments);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Cold start / web can leave [NavigatorState] unavailable for a few frames.
  Future<bool> _pushNamedWithRetry(String routeName, Object? arguments) async {
    const delaysMs = <int>[0, 16, 50, 100, 200, 400];
    for (final ms in delaysMs) {
      if (ms > 0) {
        await Future<void>.delayed(Duration(milliseconds: ms));
      }
      if (_pushNamed(routeName, arguments)) {
        return true;
      }
    }
    return false;
  }

  void _pushFallback({String? fallbackUrl, String? message}) {
    final ctx = _navigatorKey?.currentContext;
    if (ctx == null) return;
    try {
      Navigator.of(ctx).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => DeepLinkFallbackScreen(
            message: message,
            fallbackUrl: fallbackUrl,
          ),
        ),
      );
    } catch (_) {}
  }

  /// Call after successful login when token has been saved.
  Future<void> resumePendingIfAny() async {
    final raw = SharedPreferencesHelper.getData(key: _pendingKey);
    if (raw == null) return;
    final url = raw.toString().trim();
    if (url.isEmpty) return;
    await SharedPreferencesHelper.removeData(key: _pendingKey);
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await handleIncomingUri(uri, isResume: true);
  }
}
