import 'dart:io';

import 'package:path_provider/path_provider.dart';

IOSink? _sink;
String? _logFilePath;

Future<String?> initDebugLogStorage() async {
  final dir = await getApplicationSupportDirectory();
  final logDir = Directory('${dir.path}/logs');
  if (!await logDir.exists()) {
    await logDir.create(recursive: true);
  }

  final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
  final file = File('${logDir.path}/debug_$timestamp.log');
  _sink = file.openWrite(mode: FileMode.append);
  _logFilePath = file.path;
  return _logFilePath;
}

Future<void> writeDebugLogLine(String line) async {
  final sink = _sink;
  if (sink == null) return;

  try {
    sink.writeln(line);
    await sink.flush();
  } catch (_) {}
}

Future<void> closeDebugLogStorage() async {
  try {
    await _sink?.flush();
    await _sink?.close();
  } catch (_) {}
  _sink = null;
}
