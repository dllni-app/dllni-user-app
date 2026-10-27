import 'package:flutter/material.dart';

import '../../../../core/themes/shared_platform_colors.dart';
import '../../data/models/cleaning_orders_api_models.dart';
import 'v7_order_detail_components.dart';

/// Booking-wide room requirements only. No worker owns an individual room.
class CleaningRoomAssignmentsSectionWidget extends StatelessWidget {
  const CleaningRoomAssignmentsSectionWidget({
    super.key,
    required this.roomAssignments,
  });

  final List<CleaningRoomAssignmentModel> roomAssignments;

  @override
  Widget build(BuildContext context) {
    if (roomAssignments.isEmpty) return const SizedBox.shrink();

    return V7OrderPanel(
      title: 'الغرف المطلوبة',
      subtitle: 'الغرف والخدمات المشمولة في الطلب لجميع أفراد الفريق',
      child: Column(
        children: [
          for (var index = 0; index < roomAssignments.length; index++) ...[
            if (index > 0) const Divider(height: 20, color: Color(0xFFE6E9EF)),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: SharedPlatformColors.cleaningSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.meeting_room_outlined,
                    color: Color(0xFF087D83),
                    size: 21,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    roomAssignments[index].localizedDisplayLabel,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: SharedPlatformColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
