import 'package:flutter_test/flutter_test.dart';
import 'package:dllni_user_app/features/cl_main/data/models/cleaning_room_catalog_model.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_room_size_breakdown.dart';

void main() {
  test('decodes room catalog returned by the dashboard-backed API', () {
    final rooms = parseCleaningRoomCatalog({
      'success': true,
      'data': [
        {
          'code': 'kitchen',
          'name': 'المطبخ',
          'iconKey': 'kitchen',
          'sortOrder': 2,
        },
        {
          'code': 'bedroom',
          'name': 'غرفة النوم',
          'iconKey': 'bedroom',
          'sortOrder': 1,
        },
      ],
    });

    expect(rooms.map((room) => room.code).toList(), ['bedroom', 'kitchen']);
    expect(rooms.first.iconKey, 'bedroom');
    expect(rooms.first.name, 'غرفة النوم');
  });

  test('handles nested suite configuration and inactive room', () {
    final rooms = parseCleaningRoomCatalog({
      'data': {
        'roomTypes': [
          {
            'code': 'corridor',
            'name': 'الممر',
            'iconKey': 'corridor',
            'isActive': false,
          },
        ],
      },
    });
    expect(rooms, hasLength(1));
    expect(rooms.single.active, isFalse);
    expect(parseCleaningRoomCatalog({'data': {}}), isEmpty);
  });

  test(
    'only active valid codes can be selected, but current draft rooms remain',
    () {
      final catalog = parseCleaningRoomCatalog({
        'data': [
          {'code': 'study_room', 'name': 'مكتب', 'iconKey': 'study'},
          {
            'code': 'bedroom',
            'name': 'غرفة النوم',
            'iconKey': 'bedroom',
            'isActive': false,
          },
          {'code': 'storage-unsafe', 'name': 'مستودع'},
          {'code': 'utility_room', 'name': 'خدمات', 'isActive': true},
        ],
      });
      expect(selectableRoomTypes(catalog).map((room) => room.apiKey), [
        'study_room',
        'utility_room',
      ]);
      expect(
        selectableRoomTypes(
          catalog,
          selected: [
            CleaningRoomType.bedroom,
            CleaningRoomType.fromCode('archived_area'),
          ],
        ).map((room) => room.apiKey),
        ['study_room', 'utility_room', 'bedroom', 'archived_area'],
      );
    },
  );
}
