import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

@lazySingleton
class LoggerInterceptor extends Interceptor {
  static const int _maxLogBodyLength = 8000;

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

    _logger.i(_formatRequest(options));
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

    _logger.i(_formatResponse(response));
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

    _logger.e(_formatError(err));
    handler.next(err);
  }

  String _formatRequest(RequestOptions request) {
    final buffer = StringBuffer()
      ..writeln('==================== API REQUEST ====================')
      ..writeln('Method: ${request.method}')
      ..writeln('URL: ${request.uri}')
      ..writeln('Path: ${request.path}');

    if (request.queryParameters.isNotEmpty) {
      buffer
        ..writeln('Query Params:')
        ..writeln(_formatPayload(request.queryParameters));
    }

    buffer
      ..writeln('Body:')
      ..writeln(_formatPayload(request.data))
      ..writeln('=====================================================');

    return buffer.toString().trimRight();
  }

  String _formatResponse(Response response) {
    final request = response.requestOptions;
    final buffer = StringBuffer()
      ..writeln('==================== API RESPONSE ===================')
      ..writeln('Method: ${request.method}')
      ..writeln('URL: ${request.uri}')
      ..writeln('Status: ${response.statusCode} ${response.statusMessage ?? ''}'.trimRight())
      ..writeln('Data:')
      ..writeln(_formatPayload(response.data))
      ..writeln('=====================================================');

    return buffer.toString().trimRight();
  }

  String _formatError(DioException err) {
    final request = err.requestOptions;
    final response = err.response;
    final buffer = StringBuffer()
      ..writeln('==================== API ERROR ======================')
      ..writeln('Method: ${request.method}')
      ..writeln('URL: ${request.uri}')
      ..writeln('Status: ${response?.statusCode ?? 'UNKNOWN'} ${response?.statusMessage ?? ''}'.trimRight())
      ..writeln('Type: ${err.type}')
      ..writeln('Message: ${err.message}');

    if (request.queryParameters.isNotEmpty) {
      buffer
        ..writeln('Request Query Params:')
        ..writeln(_formatPayload(request.queryParameters));
    }

    buffer
      ..writeln('Request Body:')
      ..writeln(_formatPayload(request.data));

    if (response != null) {
      buffer
        ..writeln('Response Data:')
        ..writeln(_formatPayload(response.data));
    }

    buffer.writeln('=====================================================');

    return buffer.toString().trimRight();
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
