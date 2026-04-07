import 'package:common_package/common_package.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/app_app_bars.dart';

@AutoRoutePage(path: "/sm_shopping_list_details")
class SmShoppingListDetailsScreen extends StatelessWidget {
  const SmShoppingListDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F4F4),
      body: Column(
        children: [
          AppSimpleAppBar2(
            title: "قائمة تسوق المنزل",
            arrowBackType: ArrowBackType.cupertino,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                spacing: 24,
                children: [
                  ListView.separated(
                    itemCount: 3,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    separatorBuilder: (_, _) => SizedBox(height: 16),
                    itemBuilder: (_, index) => Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        border: Border.all(color: Color(0xFFF3F4F6)),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 1),
                            blurRadius: 2,
                            color: Color(0x0D000000),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 12,
                        children: [
                          Row(
                            spacing: 12,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Color(0x2B22C55E),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                ),
                                child: FaIcon(
                                  FontAwesomeIcons.bagShopping,
                                  size: 20,
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                              Expanded(
                                child: AppText(
                                  "قائمة تسوق المنزل",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    color: Color(0xFF111827),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    height: 24 / 16,
                                  ),
                                ),
                              ),
                              CupertinoSwitch(
                                value: true,
                                onChanged: (value) {},
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 32,
                            children: [
                              SizedBox(
                                width: 32,
                                height: 32,
                                child: InkWell(
                                  onTap: () {},
                                  customBorder: CircleBorder(),
                                  child: Center(
                                    child: FaIcon(
                                      FontAwesomeIcons.minus,
                                      size: 24,
                                      color: Color(0xFF4CAF50),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                child: AppText(
                                  "1",
                                  style: TextStyle(
                                    color: Color(0xFF111827),
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    height: 40 / 24,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 32,
                                height: 32,
                                child: InkWell(
                                  onTap: () {},
                                  customBorder: CircleBorder(),
                                  child: Center(
                                    child: FaIcon(
                                      FontAwesomeIcons.plus,
                                      size: 24,
                                      color: Color(0xFF4CAF50),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: context.width,
                            padding: EdgeInsets.only(top: 14, bottom: 13),
                            decoration: BoxDecoration(
                              color: Color(0x1464748B),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                              border: Border.all(color: Color(0xFF64748B)),
                            ),
                            child: AppText(
                              "حذف المنتج من القائمة",
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                height: 16 / 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      print("عنوان");
                    },
                    child: Container(
                      width: context.width,
                      padding: EdgeInsets.only(top: 14, bottom: 13),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: AppText(
                        "إعادة طلب هذه  القائمة",
                        style: TextStyle(
                          color: Color(0xFFFFEEFF),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 16 / 14,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    spacing: 22,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            print("تعديل قائمة التسوق");
                          },
                          child: Container(
                            padding: EdgeInsets.only(top: 13, bottom: 12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: .17),
                              border: Border.all(color: AppColors.primary),
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            child: AppText(
                              "تعديل قائمة التسوق",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                height: 16 / 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            print("عنوان");
                          },
                          child: Container(
                            padding: EdgeInsets.only(top: 13, bottom: 12),
                            decoration: BoxDecoration(
                              color: Color(0xFFFCEBEB),
                              border: Border.all(color: Color(0xFFDC2626)),
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            child: AppText(
                              "حذف قائمة التسوق",
                              style: TextStyle(
                                color: Color(0xFFDC2626),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                height: 16 / 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
