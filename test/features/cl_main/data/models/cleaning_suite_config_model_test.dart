import 'package:dllni_user_app/features/cl_main/data/models/cleaning_suite_config_model.dart';
import 'package:dllni_user_app/features/cl_main/view/helpers/cl_event_collected_fields.dart';
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

  test(
    'admin-configured event fields keep required flags and select options',
    () {
      final config = cleaningSuiteConfigModelFromJson({
        'data': {
          'eventTypes': [
            {
              'id': 1,
              'name': 'مناسبة',
              'slug': 'family_dinner',
              'fields': [
                {
                  'id': 7,
                  'key': 'venue_type',
                  'label': 'نوع المكان',
                  'type': 'select',
                  'required': true,
                  'options': ['home', 'hall', 'garden', 'office'],
                },
                {
                  'id': 8,
                  'key': 'special_notes',
                  'label': 'ملاحظات إضافية',
                  'type': 'textarea',
                  'required': false,
                },
                {
                  'id': 9,
                  'key': 'need_tables',
                  'type': 'boolean',
                  'required': false,
                },
              ],
            },
          ],
        },
      });
      final fields = config.eventTypes.single.fields;
      expect(fields[0].type, 'single_select');
      expect(fields[0].required, true);
      expect(fields[0].options, ['home', 'hall', 'garden', 'office']);
      expect(fields[1].type, 'textarea');
      expect(fields[2].type, 'yes_no');
    },
  );

  test('serialized admin options are parsed without changing API values', () {
    final field = CleaningDynamicFieldConfigModel.fromJson({
      'id': 4,
      'key': 'venue_type',
      'label': 'نوع المكان',
      'field_type': 'select',
      'is_required': 1,
      'options':
          '[{"value":"hall","label":"صالة"},{"value":"home","label":"منزل"}]',
    });
    expect(field.type, 'single_select');
    expect(field.required, true);
    expect(field.options.length, 2);
    expect(resolveEventVenueType({'venue_type': 'hall'}), 'hall');
    expect(resolveEventVenueType({'venueType': 'garden'}), 'garden');
    expect(resolveEventVenueType({}), 'apartment');
  });
}
