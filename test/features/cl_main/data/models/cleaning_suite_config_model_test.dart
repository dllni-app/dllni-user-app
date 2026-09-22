import 'package:dllni_user_app/features/cl_main/data/models/cleaning_suite_config_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses the v2 capability version and authoritative server time', () {
    final config = cleaningSuiteConfigModelFromJson(<String, dynamic>{
      'success': true,
      'data': <String, dynamic>{
        'schemaVersion': 2,
        'serverNow': '2026-09-10T12:30:00+03:00',
        'capabilities': <String, dynamic>{'dynamicEventTypes': true},
      },
    });

    expect(config.schemaVersion, 2);
    expect(config.serverNow, '2026-09-10T12:30:00+03:00');
    expect(config.capabilities['dynamicEventTypes'], isTrue);
  });
}
