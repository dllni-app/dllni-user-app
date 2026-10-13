import 'package:flutter/material.dart';

import '../../../../core/themes/shared_platform_colors.dart';
import '../../domain/models/cleaning_room_size_breakdown.dart';
import 'cl_service_section_card_widget.dart';

/// Short, scannable booking confirmation, never a raw API payload.
class ClBookingReviewOverview extends StatelessWidget {
  const ClBookingReviewOverview({
    super.key,
    required this.service,
    required this.address,
    required this.workerLabel,
    required this.materialsRequested,
    this.missingMaterialNames = const <String>[],
    this.missingMaterialTypeIds,
    required this.services,
    this.recurring = false,
    this.roomSizeBreakdown,
  });

  final String service;
  final String address;
  final String workerLabel;
  final bool materialsRequested;
  final List<String> missingMaterialNames;
  final List<int>? missingMaterialTypeIds;
  final List<String> services;
  final bool recurring;
  final CleaningRoomSizeBreakdown? roomSizeBreakdown;

  String get _materialLabel {
    if (!materialsRequested) {
      return 'المواد متوفرة لدى العميل';
    }
    if (missingMaterialTypeIds == null) {
      return 'الفريق يوفر جميع المواد المطلوبة';
    }
    if (missingMaterialNames.isNotEmpty && missingMaterialNames.length <= 2) {
      return 'الفريق يوفر الناقص: ${missingMaterialNames.join('، ')}';
    }
    return 'الفريق يوفر ${missingMaterialTypeIds!.length} مواد ناقصة';
  }

  @override
  Widget build(BuildContext context) {
    final rooms = roomSizeBreakdown == null
        ? 0
        : roomSizeBreakdown!.bedroom.total +
              roomSizeBreakdown!.bathroom.total +
              roomSizeBreakdown!.kitchen.total +
              roomSizeBreakdown!.livingRoom.total +
              roomSizeBreakdown!.balcony.total +
              roomSizeBreakdown!.corridor.total +
              roomSizeBreakdown!.shed.total;
    return ClServiceSectionCardWidget(
      title: 'تفاصيل الحجز',
      step: 0,
      showStepBadge: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ReviewInfoRow(
            icon: Icons.cleaning_services_outlined,
            label: 'الخدمة',
            value: service,
          ),
          if (rooms > 0) ...[
            const SizedBox(height: 14),
            _ReviewInfoRow(
              icon: Icons.home_work_outlined,
              label: 'المكان',
              value: '$rooms غرف ومساحات',
            ),
          ],
          const SizedBox(height: 14),
          _ReviewInfoRow(
            icon: Icons.location_on_outlined,
            label: 'العنوان',
            value: address,
            maxLines: 3,
          ),
          const SizedBox(height: 14),
          _ReviewInfoRow(
            icon: Icons.groups_outlined,
            label: 'الفريق',
            value: workerLabel,
          ),
          const SizedBox(height: 14),
          _ReviewInfoRow(
            icon: Icons.inventory_2_outlined,
            label: 'المواد',
            value: _materialLabel,
            maxLines: 2,
          ),
          if (services.isNotEmpty) ...[
            const SizedBox(height: 14),
            _ReviewInfoRow(
              icon: Icons.auto_awesome_outlined,
              label: 'خدمات متخصصة',
              value: services.length <= 2
                  ? services.join('، ')
                  : '${services.length} خدمات مختارة',
            ),
          ],
          if (recurring) ...[
            const SizedBox(height: 14),
            const _ReviewInfoRow(
              icon: Icons.event_repeat_outlined,
              label: 'التكرار',
              value: 'زيارات متكررة',
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewInfoRow extends StatelessWidget {
  const _ReviewInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.maxLines = 2,
  });

  final IconData icon;
  final String label;
  final String value;
  final int maxLines;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFFEDF3FF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 19, color: SharedPlatformColors.primary),
      ),
      const SizedBox(width: 10),
      SizedBox(
        width: 73,
        child: Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: SharedPlatformColors.muted,
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            value,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: SharedPlatformColors.ink,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    ],
  );
}
