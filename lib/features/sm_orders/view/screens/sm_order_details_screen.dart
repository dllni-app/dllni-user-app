import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/app_images.dart';
import '../../../../core/widgets/app_app_bars.dart';
import '../widgets/order_details_card.dart';
import '../widgets/order_status_card.dart';
import '../widgets/store_location_card.dart';

@AutoRoutePage(path: "/order_details")
class SmOrderDetailsScreen extends StatelessWidget {
  const SmOrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: Column(
        children: [
          AppSimpleAppBar(title: "تتبع الطلب"),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: context.width,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 12),
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
                    child: Text(
                      "طلب #10425",
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 25 / 20,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Color(0xFFEFF6FF),
                          child: FaIcon(
                            FontAwesomeIcons.solidClock,
                            size: 30,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        SizedBox(width: 16),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              "الوقت المتوقع للوصول",
                              style: TextStyle(
                                color: Color(0xFF2F2B3DB2),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                height: 20 / 14,
                              ),
                            ),
                            AppText(
                              "20 دقيقة",
                              style: TextStyle(
                                color: Color(0xFF1E3A8A),
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                height: 28 / 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  StoreLocationCard(),
                  SizedBox(height: 24),
                  OrderStatusCard(),
                  SizedBox(height: 24),
                  StoreInfo(),
                  SizedBox(height: 24),
                  OrderDetailsCard(),
                  SizedBox(height: 24),
                  Container(
                    width: context.width,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      border: Border.all(color: Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.message,
                          size: 14,
                          color: Color(0xFF1E293B),
                        ),
                        SizedBox(width: 8),
                        AppText(
                          "محادثة الدعم",
                          style: TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 20 / 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StoreInfo extends StatelessWidget {
  const StoreInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.all( Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 1),
            blurRadius: 2,
            color: Color(0x0D000000),
          ),
        ],
      ),
      child: Row(
        children: [
          AppImage.asset(
            AppImages.store,
            fit: BoxFit.cover,
            size: 56,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                AppText(
                  "متجر النور",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 20 / 14,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.solidStar,
                      size: 12,
                      color: Color(0xFFFACC15),
                    ),
                    SizedBox(width: 4.5),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "4.8",
                            style: TextStyle(color: AppColors.primary),
                          ),
                          TextSpan(text: " • غذائية منظفات"),
                        ],
                      ),
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 16 / 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {},
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFFF8FAFC),
              child: FaIcon(
                FontAwesomeIcons.phone,
                size: 16,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
