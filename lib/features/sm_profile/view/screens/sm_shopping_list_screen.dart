import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/app_app_bars.dart';

@AutoRoutePage(path: "/sm_shopping_list")
class SmShoppingListScreen extends StatelessWidget {
  const SmShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      body: Column(
        children: [
          AppSimpleAppBar2(
            title: "قائمة التسوق الذكي",
            arrowBackType: ArrowBackType.cupertino,
          ),
          Expanded(
            child: ListView.separated(
              itemCount: 3,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              separatorBuilder: (_, _) => SizedBox(height: 16),
              itemBuilder: (_, index) => GestureDetector(
                onTap: () {
                  context.pushRoute("/sm_shopping_list_details");
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Row(
                    spacing: 12,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Color(0x2B22C55E),
                          borderRadius: BorderRadius.all(Radius.circular(12)),
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
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: FaIcon(
                          FontAwesomeIcons.penToSquare,
                          size: 17,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        color: Color(0xFFF9FAFB),
        child: GestureDetector(
          onTap: () {
            print("عنوان");
          },
          child: Container(
            padding: EdgeInsets.only(top: 14, bottom: 13),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: AppText(
              "إضافة قائمة تسوق جديدة",
              style: TextStyle(
                color: Color(0xFFFFEEFF),
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 16 / 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
