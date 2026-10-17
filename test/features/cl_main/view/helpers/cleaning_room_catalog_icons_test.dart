import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_room_size_breakdown.dart';
import 'package:dllni_user_app/features/cl_main/view/helpers/cleaning_room_catalog_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses configured semantic icon keys for new custom room types', () {
    final study = CleaningRoomType.fromCode('study_room');
    expect(
      cleaningRoomCatalogIcon(study, iconKey: 'office'),
      Icons.desktop_windows_outlined,
    );
    expect(
      cleaningRoomCatalogIcon(study, iconKey: 'unknown-icon-key'),
      Icons.home_outlined,
    );
    expect(cleaningRoomCatalogIcon(study), Icons.home_outlined);
  });

  test('unknown configured icons fall back to familiar legacy icons', () {
    expect(
      cleaningRoomCatalogIcon(
        CleaningRoomType.kitchen,
        iconKey: 'custom_dashboard_icon',
      ),
      Icons.soup_kitchen_outlined,
    );
  });
}
