import 'dart:async';

import 'package:dio/dio.dart';

class UnauthorizedInterceptor extends Interceptor {
  UnauthorizedInterceptor({
    this.onUnauthorized,
    this.excludedPathSuffixes = const <String>[],
  });

  final Future<void> Function()? onUnauthorized;
  final List<String> excludedPathSuffixes;

  static bool _isHandlingUnauthorized = false;

  bool _isExcludedPath(String requestPath) {
    return excludedPathSuffixes.any(
      (suffix) => requestPath.endsWith(suffix),
    );
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final requestPath = err.requestOptions.path;

    if (statusCode == 401 &&
        !_isExcludedPath(requestPath) &&
        !_isHandlingUnauthorized) {
      _isHandlingUnauthorized = true;
      try {
        await onUnauthorized?.call();
      } finally {
        _isHandlingUnauthorized = false;
      }
    }

    super.onError(err, handler);
  }
}
