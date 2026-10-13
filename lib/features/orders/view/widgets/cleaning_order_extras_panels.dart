import 'package:flutter/material.dart';

import '../../../../core/models/cleaning_service_extras.dart';
import '../../../cl_main/view/widgets/cl_cleaning_extras_section_widget.dart';
import 'v7_order_detail_components.dart';

/// Builds independent order detail cards, omitting every empty category.
List<Widget> buildCleaningOrderExtrasPanels({
  required List<CleaningMaterialLineModel> materials,
  required List<CleaningSpecialServiceLineModel> specialServices,
  required CleaningOpenTimeModel? openTime,
  required String currency,
}) {
  return <Widget>[
    if (materials.isNotEmpty)
      V7OrderPanel(
        key: const ValueKey('order-materials-panel'),
        title: 'مواد التنظيف',
        subtitle: 'المواد التي يوفرها فريق التنظيف لهذا الطلب',
        leading: const Icon(Icons.inventory_2_outlined),
        child: CleaningOrderMaterialLines(
          materials: materials,
          currency: currency,
        ),
      ),
    if (specialServices.isNotEmpty)
      V7OrderPanel(
        key: const ValueKey('order-special-services-panel'),
        title: 'الخدمات المتخصصة',
        subtitle: 'الخدمات الإضافية المطلوبة خارج التنظيف الأساسي',
        leading: const Icon(Icons.auto_awesome_outlined),
        child: CleaningOrderSpecialServiceLines(
          specialServices: specialServices,
          currency: currency,
        ),
      ),
    if (openTime != null)
      V7OrderPanel(
        key: const ValueKey('order-hourly-work-panel'),
        title: 'تفاصيل العمل بالساعة',
        leading: const Icon(Icons.schedule_outlined),
        child: CleaningOrderHourlyDetails(
          openTime: openTime,
          currency: currency,
        ),
      ),
  ];
}
