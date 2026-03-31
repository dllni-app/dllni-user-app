import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/app_colors.dart';
import '../widgets/added_products_section.dart';
import '../widgets/cart_main_button.dart';
import '../widgets/cart_simple_app_bar.dart';
import '../widgets/coupon_section.dart';
import '../widgets/summary_request.dart';

@AutoRoutePage(path: "/cart")
class SmCartScreen extends StatelessWidget {
  const SmCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CartSimpleAppBar(
            title: "سلتك",
            backTo: "سوبر ماركت النور"),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 39),
                  AddedProductsSection(),
                  SizedBox(height: 16),
                  Divider(color: Color(0xFFD9D9D9), height: 4),
                  SizedBox(height: 24),
                  CouponSection(),
                  SizedBox(height: 16),
                  SummaryRequest(),
                  SizedBox(height: 24),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: CartMainButton(label: "متابعة", onTap: () {
                      context.pushRoute("/cart_details");
                    }),
                  ),
                  SizedBox(height: 47),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
