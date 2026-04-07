import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/app_images.dart';
import '../../../../core/widgets/app_app_bars.dart';
import '../widgets/address_card.dart';
import '../widgets/order_content.dart';
import '../widgets/order_details_status_card.dart';
import '../widgets/order_info_card.dart';
import '../widgets/summary_request.dart';

@AutoRoutePage(path: "/order_details")
class SmOrderDetailsScreen extends StatelessWidget {
  const SmOrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: Column(
        children: [
          AppSimpleAppBar2(
            title: "تفاصيل الطلب",
            arrowBackType: ArrowBackType.cupertino,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OrderStatus(),
                  SizedBox(height: 16),
                  AppText(
                    "معلومات الطلب",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 28 / 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  OrderInfoCard(),
                  SizedBox(height: 16),
                  AddressCard(),
                  SizedBox(height: 16),
                  OrderContent(),
                  SizedBox(height: 16),
                  SummaryRequest(),
                  SizedBox(height: 16),
                  OrderButton(),
                  SizedBox(height: 16),
                  OrderOutlineButton(),
                  SizedBox(height: 70),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderOutlineButton extends StatelessWidget {
  const OrderOutlineButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: context.width,
        padding: EdgeInsets.only(top: 14, bottom: 13),
        decoration: BoxDecoration(
          color: Color(0xFFE2E4E6),
          borderRadius: BorderRadius.all(Radius.circular(8)),
          border: Border.all(color: Color(0xFF64748B)),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 2),
              blurRadius: 5.2,
              color: Color(0x40000000),
            ),
          ],
        ),
        child: AppText(
          "إلغاء الطلب",
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            height: 28 / 18,
          ),
        ),
      ),
    );
  }
}

class OrderButton extends StatelessWidget {
  const OrderButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: context.width,
        padding: EdgeInsets.only(top: 14, bottom: 13),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.all(Radius.circular(8)),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 2),
              blurRadius: 5.2,
              color: Color(0x40000000),
            ),
          ],
        ),
        child: AppText(
          "إعادة الطلب",
          style: TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            height: 28 / 18,
          ),
        ),
      ),
    );
  }
}
