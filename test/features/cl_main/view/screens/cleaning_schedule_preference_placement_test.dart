import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _source(String path) => File(path).readAsStringSync();

void main() {
  group('cleaning provider preference placement', () {
    test('regular home preference is shown on the schedule screen only', () {
      final description = _source(
        'lib/features/cl_main/view/screens/cl_main_home_description_screen.dart',
      );
      final schedule = _source(
        'lib/features/cl_main/view/screens/cl_main_service_schedule_screen.dart',
      );

      expect(
        description.contains('ClServiceGenderPreferenceSectionWidget('),
        isFalse,
      );
      expect(
        schedule.contains('ClServiceGenderPreferenceSectionWidget('),
        isTrue,
      );
    });

    test('occasion provider controls are shown on the schedule screen only', () {
      final description = _source(
        'lib/features/cl_main/view/screens/cl_main_occasion_description_screen.dart',
      );
      final schedule = _source(
        'lib/features/cl_main/view/screens/cl_main_occasion_schedule_screen.dart',
      );

      expect(
        description.contains('ClServiceGenderPreferenceSectionWidget('),
        isFalse,
      );
      expect(
        description.contains('ClServicePreviousWorkersSectionWidget('),
        isFalse,
      );
      expect(
        schedule.contains('ClServiceGenderPreferenceSectionWidget('),
        isTrue,
      );
      expect(
        schedule.contains('ClServicePreviousWorkersSectionWidget('),
        isTrue,
      );
    });
  });

  test('address city is a fixed Aleppo dropdown for create and update', () {
    final addressScreen = _source(
      'lib/features/profile/view/screens/add_address_screen.dart',
    );

    expect(
      addressScreen.contains("TextEditingController(text: 'حلب')"),
      isTrue,
    );
    expect(addressScreen.contains("Key('address_city_dropdown')"), isTrue);
    expect(
      addressScreen.contains(
        "DropdownMenuItem<String>(\n                                    value: 'حلب',\n                                    child: Text('حلب')",
      ),
      isTrue,
    );
    expect(addressScreen.contains("hintText: 'مثال: دمشق'"), isFalse);
    expect(addressScreen.contains('_cityController.text = item.city'), isFalse);
  });
}
