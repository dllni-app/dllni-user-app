import 'dart:async';
import 'dart:io' show Platform;

import 'package:app_links/app_links.dart';
import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/deeplink/deep_link_dispatcher.dart';
import 'package:dllni_user_app/core/deeplink/deep_link_fallback_screen.dart';
import 'package:dllni_user_app/core/deeplink/deep_link_models.dart';
import 'package:dllni_user_app/core/deeplink/deep_link_parser.dart';
import 'package:dllni_user_app/core/deeplink/deep_link_remote_data_source.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:injectable/injectable.dart';

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
    if (_lastFingerprint == fingerprint && _lastAt != null && now.difference(_lastAt!) < _dedupe) {
      return true;
    }
    _lastFingerprint = fingerprint;
    _lastAt = now;
    return false;
  }

  Map<String, String> _utmFromUri(Uri uri) {
    final q = uri.queryParameters;
    return <String, String>{
      if (q['utm_source'] != null) 'source': q['utm_source']!,
      if (q['utm_medium'] != null) 'medium': q['utm_medium']!,
      if (q['utm_campaign'] != null) 'campaign': q['utm_campaign']!,
    };
  }

  int? _sharerIdFromUri(Uri uri) {
    final raw = uri.queryParameters['sharer_id'] ?? uri.queryParameters['sharerId'];
    if (raw == null || raw.isEmpty) return null;
    return int.tryParse(raw);
  }

  Future<void> handleIncomingUri(Uri uri, {bool isResume = false}) async {
    final normalized = DeepLinkParser.normalizeHostIfNeeded(uri);
    if (!DeepLinkParser.isSupportedDeepLink(normalized)) {
      return;
    }

    final urlStr = normalized.toString();
    if (_isDuplicate('$isResume|$urlStr')) {
      return;
    }

    final utm = _utmFromUri(normalized);
    final sharerId = _sharerIdFromUri(normalized);
    final platform = _platformLabel();

    await _remoteDataSource.postDeepLinkEvent(
      action: 'link_received',
      url: urlStr,
      source: utm['source'],
      medium: utm['medium'],
      campaign: utm['campaign'],
      sharerId: sharerId,
      platform: platform,
    );

    final resolved = await _remoteDataSource.resolve(urlStr);

    if (resolved != null) {
      await _remoteDataSource.postDeepLinkEvent(
        action: 'link_resolved',
        url: resolved.canonicalUrl ?? urlStr,
        source: utm['source'],
        medium: utm['medium'],
        campaign: utm['campaign'],
        sharerId: sharerId,
        platform: platform,
      );
    }

    final pendingUrl = (resolved?.canonicalUrl != null && resolved!.canonicalUrl!.trim().isNotEmpty)
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

    DeepLinkDispatchTarget? apiTarget;
    if (resolved != null && resolved.status == DeepLinkResolveStatus.ok) {
      apiTarget = DeepLinkDispatcher.dispatch(resolved);
    }
    final localTarget = DeepLinkDispatcher.dispatchFromCanonicalUri(normalized);
    final target = apiTarget ?? localTarget;

    if (resolved != null && resolved.status == DeepLinkResolveStatus.expired) {
      await _emitFailed(urlStr, utm, sharerId, platform);
      _pushFallback(fallbackUrl: resolved.fallbackUrl, message: _messageForStatus(DeepLinkResolveStatus.expired));
      return;
    }

    if (resolved != null &&
        resolved.status == DeepLinkResolveStatus.forbidden &&
        !resolved.requiresAuth) {
      await _emitFailed(urlStr, utm, sharerId, platform);
      _pushFallback(fallbackUrl: resolved.fallbackUrl, message: _messageForStatus(DeepLinkResolveStatus.forbidden));
      return;
    }

    if (target == null) {
      await _emitFailed(urlStr, utm, sharerId, platform);
      if (resolved == null) {
        _pushFallback(fallbackUrl: null, message: 'تعذر التحقق من الرابط.');
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

    final pushed = await _pushNamedWithRetry(target.routeName, target.arguments);
    if (pushed) {
      await _remoteDataSource.postDeepLinkEvent(
        action: 'link_open_success',
        url: resolved?.canonicalUrl ?? urlStr,
        source: utm['source'],
        medium: utm['medium'],
        campaign: utm['campaign'],
        sharerId: sharerId,
        platform: platform,
      );
    } else {
      await _emitFailed(urlStr, utm, sharerId, platform);
    }
  }

  bool _routeNeedsLocalAuth(DeepLinkDispatchTarget target) {
    return target.routeName == '/votefollowup' || target.routeName == '/group-order/followup';
  }

  Future<void> _emitFailed(
    String url,
    Map<String, String> utm,
    int? sharerId,
    String platform,
  ) async {
    await _remoteDataSource.postDeepLinkEvent(
      action: 'link_open_failed',
      url: url,
      source: utm['source'],
      medium: utm['medium'],
      campaign: utm['campaign'],
      sharerId: sharerId,
      platform: platform,
    );
  }

  String? _messageForStatus(DeepLinkResolveStatus st) {
    switch (st) {
      case DeepLinkResolveStatus.notFound:
        return 'الرابط غير موجود.';
      case DeepLinkResolveStatus.expired:
        return 'انتهت صلاحية هذا الرابط.';
      case DeepLinkResolveStatus.forbidden:
        return 'لا يمكنك الوصول إلى هذا المحتوى.';
      default:
        return 'تعذر فتح هذا الرابط.';
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
