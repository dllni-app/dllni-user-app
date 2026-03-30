import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StoreInfoSection extends StatelessWidget {
  const StoreInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              Column(
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
                  AppText(
                    "شارع الملك فيصل، حي المحافظة",
                    style: TextStyle(
                      color: Color(0xFF4B5563),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 20 / 14,
                    ),
                  ),
                  AppText(
                    "1.2 كم منك",
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 16 / 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
      
          SizedBox(height: 16),
          Row(
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
              Column(
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
                  AppText(
                    "السبت - الخميس: 10:00 ص - 2:00 ص",
                    style: TextStyle(
                      color: Color(0xFF4B5563),
                      fontSize: 14,
                      height: 20 / 14,
                    ),
                  ),
                  AppText(
                    "الجمعة: 12:00 م - 2:00 ص",
                    style: TextStyle(
                      color: Color(0xFF4B5563),
                      fontSize: 14,
                      height: 20 / 14,
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
