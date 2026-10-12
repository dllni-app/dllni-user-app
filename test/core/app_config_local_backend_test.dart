import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:dllni_user_app/core/app_config.dart';

void main() {
  test('debug emulator app defaults to developer Laravel HTTP port', () {
    if (!kReleaseMode) {
      expect(AppConfig.baseUrl, 'http://127.0.0.1:8000');
    }
  });
}
