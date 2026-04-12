import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/themes/app_colors.dart';

class StoreAddressSection extends StatelessWidget {
  const StoreAddressSection({
    super.key,
    this.address,
    this.phone,
    this.email,
    this.distanceKm,
    this.hourLines = const [],
  });

  final String? address;
  final String? phone;
  final String? email;
  final double? distanceKm;
  final List<String> hourLines;

  @override
  Widget build(BuildContext context) {
    final hasAddressBlock =
        (address != null && address!.trim().isNotEmpty) ||
        distanceKm != null ||
        (phone != null && phone!.trim().isNotEmpty) ||
        (email != null && email!.trim().isNotEmpty);
    final hasHours = hourLines.isNotEmpty;

    if (!hasAddressBlock && !hasHours) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasAddressBlock) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.locationDot,
                    size: 18,
                    color: Color(0xFF4B5563),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      AppText(
                        "العنوان",
                        style: TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 20 / 14,
                        ),
                      ),
                      if (address != null && address!.trim().isNotEmpty)
                        AppText(
                          address!,
                          style: TextStyle(
                            color: Color(0xFF4B5563),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 20 / 14,
                          ),
                        ),
                      if (distanceKm != null)
                        AppText(
                          "${distanceKm!.toStringAsFixed(1)} كم منك",
                          style: TextStyle(
                            color: Color(0xFF4CAF50),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 16 / 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (hasHours) SizedBox(height: 16),
          ],
          if (hasHours)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.solidClock,
                    size: 18,
                    color: Color(0xFF4B5563),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      AppText(
                        "ساعات العمل",
                        style: TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 20 / 14,
                        ),
                      ),
                      ...hourLines.map(
                        (line) => AppText(
                          line,
                          style: TextStyle(
                            color: Color(0xFF4B5563),
                            fontSize: 14,
                            height: 20 / 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
