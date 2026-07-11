import 'dart:async';

import 'package:flutter/foundation.dart';

import 'debug_file_logger_storage_stub.dart'
    if (dart.library.io) 'debug_file_logger_storage_io.dart';

/// Captures [debugPrint], [print], and uncaught errors into a log file.
///
/// Enabled only in debug mode. On mobile/desktop the file is stored under the
/// app support directory in a `logs/` folder (one file per app session).
abstract final class DebugFileLogger {
  static bool _initialized = false;
  static DebugPrintCallback? _originalDebugPrint;
  static String? _logFilePath;

  /// Path to the active log file, or `null` when logging is disabled/unavailable.
  static String? get logFilePath => _logFilePath;

  /// Initializes file logging as early as possible in [main].
  static Future<void> init() async {
    if (_initialized || !kDebugMode) return;

    try {
      _logFilePath = await initDebugLogStorage();
      if (_logFilePath == null) return;

      _originalDebugPrint = debugPrint;
      debugPrint = _onDebugPrint;

      final previousFlutterOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        previousFlutterOnError?.call(details);
        writeToFileOnly(details.toString());
      };

      final previousPlatformOnError = PlatformDispatcher.instance.onError;
      PlatformDispatcher.instance.onError = (error, stack) {
        writeToFileOnly('PlatformDispatcher error: $error\n$stack');
        return previousPlatformOnError?.call(error, stack) ?? false;
      };

      _initialized = true;
      writeToFileOnly(
        '=== Debug log started at ${DateTime.now().toIso8601String()} ===',
      );
      writeToFileOnly('Log file: $_logFilePath');
    } catch (error, stackTrace) {
      _originalDebugPrint?.call(
        'DebugFileLogger init failed: $error\n$stackTrace',
      );
    }
  }

  /// Runs [body] inside a guarded zone that also captures [print] output.
  static Future<void> runGuarded(Future<void> Function() body) async {
    await runZonedGuarded(
      body,
      (error, stackTrace) {
        writeToFileOnly('Uncaught zone error: $error\n$stackTrace');
      },
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) {
          parent.print(zone, line);
          writeToFileOnly(line);
        },
      ),
    );
  }

  static void _onDebugPrint(String? message, {int? wrapWidth}) {
    _originalDebugPrint?.call(message, wrapWidth: wrapWidth);
    if (message != null) {
      writeToFileOnly(message);
    }
  }

  /// Writes a line to the log file with a timestamp prefix.
  static void writeToFileOnly(String message) {
    if (!_initialized || _logFilePath == null) return;

    final timestamp = DateTime.now().toIso8601String();
    for (final line in message.split('\n')) {
      unawaited(writeDebugLogLine('[$timestamp] $line'));
    }
  }

  /// Flushes and closes the active log file sink.
  static Future<void> dispose() => closeDebugLogStorage();
}
