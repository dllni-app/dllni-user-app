import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

@lazySingleton
class LoggerInterceptor extends Interceptor {
  static const int _maxLogBodyLength = 4000;

  final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 0,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (!kDebugMode) {
      handler.next(options);
      return;
    }

    final buffer = StringBuffer()
      ..writeln('🚀 ${options.method} ${options.uri}')
      ..writeln('Headers:')
      ..writeln(_formatPayload(options.headers));

    if (options.queryParameters.isNotEmpty) {
      buffer
        ..writeln('Query Parameters:')
        ..writeln(_formatPayload(options.queryParameters));
    }

    if (options.data != null) {
      buffer
        ..writeln('Body:')
        ..writeln(_formatPayload(options.data));
    }

    _logger.i(buffer.toString().trimRight());

    handler.next(options);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    if (!kDebugMode) {
      handler.next(response);
      return;
    }

    final data = response.data;
    String summary = '';

    if (data is List) {
      summary = 'items=${data.length}';
    } else if (data is Map) {
      summary = data.containsKey('data') && data['data'] is List
          ? 'items=${(data['data'] as List).length}'
          : 'keys=${data.keys.length}';
    }

    _logger.i(
      '✅ ${response.statusCode} '
      '${response.requestOptions.method} '
      '${response.requestOptions.uri}'
      '${summary.isNotEmpty ? ' ($summary)' : ''}\n'
      'Body:\n${_formatPayload(data)}',
    );

    handler.next(response);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    if (!kDebugMode) {
      handler.next(err);
      return;
    }

    final request = err.requestOptions;
    final requestBody = request.data == null ? '' : _formatPayload(request.data);
    final responseBody = err.response?.data == null ? '' : _formatPayload(err.response?.data);

    _logger.e(
      '❌ ${err.response?.statusCode ?? 'UNKNOWN'} '
      '${request.method} '
      '${request.uri}\n\n'
      'Message:\n'
      '${err.message}\n\n'
      'Type:\n'
      '${err.type}\n\n'
      'Headers:\n'
      '${_formatPayload(request.headers)}\n\n'
      'Query Parameters:\n'
      '${_formatPayload(request.queryParameters)}\n\n'
      '${requestBody.isNotEmpty ? 'Request Body:\n$requestBody\n\n' : ''}'
      '${responseBody.isNotEmpty ? 'Response Body:\n$responseBody\n\n' : ''}'
      'StackTrace:\n'
      '${err.stackTrace}',
    );

    handler.next(err);
  }

  String _formatPayload(dynamic payload) {
    if (payload == null) return 'null';

    try {
      final normalizedPayload = _normalizePayload(payload);

      if (normalizedPayload is Map || normalizedPayload is List) {
        return _truncateBody(
          const JsonEncoder.withIndent('  ').convert(normalizedPayload),
        );
      }

      return _truncateBody(normalizedPayload.toString());
    } catch (_) {
      return _truncateBody(payload.toString());
    }
  }

  dynamic _normalizePayload(dynamic payload) {
    if (payload == null || payload is num || payload is bool || payload is String) {
      return payload;
    }

    if (payload is FormData) {
      final fields = <String, dynamic>{};

      for (final field in payload.fields) {
        _appendValue(fields, field.key, field.value);
      }

      return <String, dynamic>{
        'fields': fields,
        if (payload.files.isNotEmpty)
          'files': payload.files.map((fileEntry) {
            final file = fileEntry.value;

            return <String, dynamic>{
              'field': fileEntry.key,
              'filename': file.filename,
              'contentType': file.contentType?.toString(),
              'length': file.length,
            };
          }).toList(),
      };
    }

    if (payload is Map) {
      return payload.map(
        (key, value) => MapEntry(key.toString(), _normalizePayload(value)),
      );
    }

    if (payload is Iterable) {
      return payload.map(_normalizePayload).toList();
    }

    if (payload is MultipartFile) {
      return <String, dynamic>{
        'filename': payload.filename,
        'contentType': payload.contentType?.toString(),
        'length': payload.length,
      };
    }

    if (payload is DateTime) {
      return payload.toIso8601String();
    }

    if (payload is Uri) {
      return payload.toString();
    }

    return payload.toString();
  }

  void _appendValue(Map<String, dynamic> target, String key, dynamic value) {
    if (!target.containsKey(key)) {
      target[key] = _normalizePayload(value);
      return;
    }

    final existingValue = target[key];

    if (existingValue is List) {
      existingValue.add(_normalizePayload(value));
    } else {
      target[key] = [existingValue, _normalizePayload(value)];
    }
  }

  String _truncateBody(String body) {
    if (body.length <= _maxLogBodyLength) return body;

    return '${body.substring(0, _maxLogBodyLength)} ... (truncated)';
  }
}
