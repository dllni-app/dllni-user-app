import 'dart:ui';

import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/app_app_bars.dart';

@AutoRoutePage(path: "/sm_offers")
class SmOffersScreen extends StatelessWidget {
  const SmOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppSimpleAppBar2(
            title: "حسومات",
            arrowBackType: ArrowBackType.cupertino,
            canPop: context.canPop(),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              itemCount: 3,
              separatorBuilder: (_, _) => SizedBox(height: 16),
              itemBuilder: (_, _) => Container(
                height: 192,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [AppColors.accent, Color(0xFFA24D00)],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(16)),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0x33FFFFFF),
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                      child: AppText(
                        "خصم 100%",
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 16 / 12,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    AppText(
                      "للمستخدمين الجدد",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 28 / 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    Expanded(
                      child: AppText(
                        "احصل على توصيل مجاني",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Color(0xE5FFFFFF),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 20 / 14,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              color: Color(0x33FFFFFF),
                              child: Text(
                                "صالح حتى 31 ديسمبر",
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 12,
                                  height: 16 / 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(0, 4),
                                blurRadius: 4,
                                color: Color(0x1A000000),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(width: 10),
                              AppText(
                                "#freedelivery",
                                textDirection: TextDirection.ltr,
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  height: 20 / 14,
                                ),
                              ),
                              SizedBox(width: 10),
                              FaIcon(
                                FontAwesomeIcons.copy,
                                size: 24,
                                color: AppColors.accent,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
