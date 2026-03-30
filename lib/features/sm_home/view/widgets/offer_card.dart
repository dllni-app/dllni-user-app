import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/themes/app_colors.dart';

class OfferCardData {
  final String imagePath;
  final String name;
  final String info;
  final num distance;
  final OfferType type;

  OfferCardData({
    required this.imagePath,
    required this.name,
    required this.info,
    required this.distance,
    required this.type,
  });
}

enum OfferType { limited, almostFinished, daily }

class OfferCard extends StatelessWidget {
  const OfferCard({super.key, required this.data});
  final OfferCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.all(Radius.circular(24)),
        border: Border.all(color: Color(0xFFF3F4F6)),
      ),
      child: Stack(
        fit: StackFit.loose,
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                AppImage.asset(
                  data.imagePath,
                  size: 80,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AppText(
                            data.name,
                            style: TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              height: 20 / 12,
                            ),
                          ),
                          SizedBox(width: 16),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: .1),
                              borderRadius: BorderRadius.all(
                                Radius.circular(50),
                              ),
                            ),
                            child: AppText(
                              "خصم 50%",
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                height: 16 / 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      AppText(
                        data.info,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                          height: 16 / 12,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.locationDot,
                            size: 10,
                            color: Color(0xFF9CA3AF),
                          ),
                          SizedBox(width: 8),
                          AppText(
                            "${data.distance.toStringAsFixed(1)} كم",
                            style: TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 12,
                              height: 16 / 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(16),
                  topLeft: Radius.circular(24),
                ),
              ),
              child: AppText(
                data.type == OfferType.limited
                    ? "لفترة محدودة"
                    : data.type == OfferType.almostFinished
                    ? "ينتهي قريباً"
                    : "عرض اليوم",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  height: 15 / 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
