import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/themes/app_colors.dart';

class OrderTrackingStatusCard extends StatelessWidget {
  const OrderTrackingStatusCard({
    super.key,
    this.hasDelivery = false,
    required this.step,
  });
  final bool hasDelivery;
  final int step;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 1),
            blurRadius: 2,
            color: Color(0x0D000000),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'حالة الطلب',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 28 / 18,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Column(
                    children: [
                      SizedBox(height: 5),
                      Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: step >= 1
                              ? Color(0xFF1E3A8A)
                              : Color(0xFFF1F4F8),
                          shape: BoxShape.circle,
                          border: Border.all(width: 4, color: AppColors.white),
                        ),
                        child: FaIcon(
                          FontAwesomeIcons.check,
                          size: 12,
                          color: step >= 1
                              ? AppColors.white
                              : Color(0xFFCAD1DC),
                        ),
                      ),
                      Container(
                        width: 2,
                        height: 34,
                        color: step >= 2
                            ? Color(0xFF1E3A8A)
                            : Color(0xFFCAD1DC),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: step > 2
                              ? step == 2
                                    ? AppColors.accent
                                    : Color(0xFF1E3A8A)
                              : Color(0xFFF1F4F8),
                          shape: BoxShape.circle,
                          border: Border.all(width: 4, color: AppColors.white),
                        ),
                        child: FaIcon(
                          FontAwesomeIcons.fireBurner,
                          size: 12,
                          color: step >= 2
                              ? AppColors.white
                              : Color(0xFFCAD1DC),
                        ),
                      ),
                      Container(
                        width: 2,
                        height: 34,
                        color: step >= 3
                            ? Color(0xFF1E3A8A)
                            : Color(0xFFCAD1DC),
                      ),
                      if (hasDelivery) ...[
                        Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: step > 3
                                ? step == 3
                                      ? AppColors.accent
                                      : Color(0xFF1E3A8A)
                                : Color(0xFFF1F4F8),
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 4,
                              color: AppColors.white,
                            ),
                          ),
                          child: FaIcon(
                            FontAwesomeIcons.motorcycle,
                            size: 12,
                            color: step >= 3
                                ? AppColors.white
                                : Color(0xFFCAD1DC),
                          ),
                        ),
                        Container(
                          width: 2,
                          height: 34,
                          color:
                              (step >= 3 && !hasDelivery) ||
                                  (step >= 4 && hasDelivery)
                              ? Color(0xFF1E3A8A)
                              : Color(0xFFE2E8F0),
                        ),
                      ],
                      Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color:
                              (step >= 3 && !hasDelivery) ||
                                  (step >= 4 && hasDelivery)
                              ? Color(0xFF1E3A8A)
                              : Color(0xFFF1F4F8),
                          shape: BoxShape.circle,
                          border: Border.all(width: 4, color: AppColors.white),
                        ),
                        child: FaIcon(
                          FontAwesomeIcons.house,
                          size: 12,
                          color:
                              (step >= 3 && !hasDelivery) ||
                                  (step >= 4 && hasDelivery)
                              ? AppColors.white
                              : Color(0xFFCAD1DC),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 24,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            AppText(
                              "تم استلام الطلب",
                              style: TextStyle(
                                color: Color(0xFF1E293B),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                height: 20 / 14,
                              ),
                            ),
                            SizedBox(height: 2),
                            AppText(
                              "12:30 م - تم إرسال الطلب للمتجر",
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                height: 16 / 12,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            AppText(
                              "جاري تحضير الطلب",
                              style: TextStyle(
                                color: Color(0xFF1E293B),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                height: 20 / 14,
                              ),
                            ),
                            SizedBox(height: 2),
                            AppText(
                              "12:35 م - المتجر يقوم بتجهيز طلبك",
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                height: 16 / 12,
                              ),
                            ),
                          ],
                        ),
                        if (hasDelivery)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              AppText(
                                "السائق في الطريق",
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  height: 20 / 14,
                                ),
                              ),
                              SizedBox(height: 2),
                              AppText(
                                "السائق يتجه إليك الآن",
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  height: 16 / 12,
                                ),
                              ),
                            ],
                          ),
                        Column(
                          children: [
                            SizedBox(height: 5),
                            AppText(
                              "تم استلام الطلب",
                              style: TextStyle(
                                color: Color(0xFF1E293B),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                height: 20 / 14,
                              ),
                            ),
                            SizedBox(height: 8),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
