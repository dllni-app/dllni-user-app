import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/app_app_bars.dart';
import '../widgets/added_products_section.dart';
import '../widgets/coupon_section.dart';
import '../widgets/order_note_section.dart';
import '../widgets/summary_request.dart';

@AutoRoutePage(path: "/cart")
class SmCartScreen extends StatelessWidget {
  const SmCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      body: Column(
        children: [
          AppSimpleAppBar2(title: "الطلبية الحالية"),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  AddedProductsSection(),
                  SizedBox(height: 20),
                  CouponSection(),
                  SizedBox(height: 20),
                  OrderNoteSection(),
                  SizedBox(height: 20),
                  SummaryRequest(),
                  SizedBox(height: 24),
                  // Padding(
                  //   padding: EdgeInsets.symmetric(horizontal: 16),
                  //   child: CartMainButton(
                  //     label: "متابعة",
                  //     onTap: () {
                  //       context.pushRoute("/cart_details");
                  //     },
                  //   ),
                  // ),
                  SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.paddingOf(context).bottom + 24,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        child: InkWell(
          onTap: () {
            context.pushRoute("/cart_details");
          },
          borderRadius: BorderRadius.all(Radius.circular(12)),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.all(Radius.circular(12)),
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, 4),
                  blurRadius: 6,
                  spreadRadius: -4,
                  color: Color(0x1A000000),
                ),
                BoxShadow(
                  offset: Offset(0, 10),
                  blurRadius: 15,
                  spreadRadius: -3,
                  color: Color(0x1A000000),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8,
              children: [
                AppText(
                  "تحديد طريقة استلام الطلب",
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 28 / 18,
                  ),
                ),
                FaIcon(
                  FontAwesomeIcons.arrowLeft,
                  size: 12,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 3, dashSpace = 2, startX = 0;
    final paint = Paint()
      ..color = Color(0xFFE5E7EB)
      ..strokeWidth = 1;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
