import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StoreInfoSection extends StatelessWidget {
  const StoreInfoSection({
    super.key,
    required this.address,
    required this.distanceLabel,
    required this.workingHoursLines,
  });

  final String address;
  final String distanceLabel;
  final List<String> workingHoursLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Color(0xFFF3F4F6), borderRadius: BorderRadius.all(Radius.circular(12))),
                child: FaIcon(FontAwesomeIcons.locationDot, size: 18, color: Color(0xFF4B5563)),
              ),
              SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  AppText(
                    "العنوان",
                    style: TextStyle(color: Color(0xFF111827), fontSize: 14, fontWeight: FontWeight.w700, height: 20 / 14),
                  ),
                  AppText(
                    address,
                    style: TextStyle(color: Color(0xFF4B5563), fontSize: 14, fontWeight: FontWeight.w500, height: 20 / 14),
                  ),
                  if (distanceLabel.isNotEmpty)
                    AppText(
                      distanceLabel,
                      style: TextStyle(color: Color(0xFF4CAF50), fontSize: 12, fontWeight: FontWeight.w500, height: 16 / 12),
                    ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Color(0xFFF3F4F6), borderRadius: BorderRadius.all(Radius.circular(12))),
                child: FaIcon(FontAwesomeIcons.solidClock, size: 18, color: Color(0xFF4B5563)),
              ),
              SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  AppText(
                    "ساعات العمل",
                    style: TextStyle(color: Color(0xFF111827), fontSize: 14, fontWeight: FontWeight.w700, height: 20 / 14),
                  ),
                  ...workingHoursLines.map(
                    (line) => AppText(
                      line,
                      style: TextStyle(color: Color(0xFF4B5563), fontSize: 14, height: 20 / 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
