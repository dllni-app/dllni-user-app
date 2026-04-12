import 'package:dio/dio.dart';

/// Clears session and navigates to login on HTTP 401, except for [excludedPathSuffixes].
/// Uses a static guard so concurrent 401 responses trigger [onUnauthorized] once.
class UnauthorizedInterceptor extends Interceptor {
  UnauthorizedInterceptor({
    this.onUnauthorized,
    this.excludedPathSuffixes = const [],
  });

  final Future<void> Function()? onUnauthorized;
  final List<String> excludedPathSuffixes;

  static bool _handlingUnauthorized = false;

  bool _isExcludedPath(String path) {
    for (final suffix in excludedPathSuffixes) {
      if (suffix.isEmpty) continue;
      final normalizedPath = path.endsWith('/') ? path.substring(0, path.length - 1) : path;
      final normalizedSuffix = suffix.endsWith('/') ? suffix.substring(0, suffix.length - 1) : suffix;
      if (normalizedPath.endsWith(normalizedSuffix)) return true;
    }
    return false;
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.path;

    if (statusCode == 401 && !_isExcludedPath(path)) {
      final callback = onUnauthorized;
      if (callback != null && !_handlingUnauthorized) {
        _handlingUnauthorized = true;
        try {
          await callback();
        } finally {
          _handlingUnauthorized = false;
        }
      }
    }

    super.onError(err, handler);
  }
}
