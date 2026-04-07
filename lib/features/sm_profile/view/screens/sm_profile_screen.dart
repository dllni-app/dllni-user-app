import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/app_app_bars.dart';
import '../widgets/rs_profile_summary_card.dart';
import '../widgets/section_card.dart';
import '../widgets/section_title.dart';
import 'sm_personal_details_screen.dart';

class SmProfileScreen extends StatelessWidget {
  const SmProfileScreen({super.key});

  static const SmPersonalDetailsParams _personalDetailsParams =
      SmPersonalDetailsParams(
        name: 'مطعم البيت الحلبي',
        phoneLocal: '987654321',
        dialCode: '+963',
        isPhoneVerified: true,
        email: 'ahmed.m@example.com',
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppSimpleAppBar(title: "حسابي", canPop: false),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsetsDirectional.all(16),
              child: Column(
                children: [
                  RsProfileSummaryCard(
                    params: _personalDetailsParams,
                    onEditTap: () {
                      context.pushRoute(
                        '/sm_personal_details',
                        arguments: _personalDetailsParams,
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  SectionTitle(title: 'إدارة الحساب'),
                  SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: AppColors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x0F000000),
                          offset: Offset(0, 1),
                          blurRadius: 2,
                        ),
                        BoxShadow(
                          color: Color(0x1A000000),
                          offset: Offset(0, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    padding: EdgeInsetsDirectional.all(16),
                    child: Column(
                      children: [
                        SectionCard(
                          containerColor: Color(0xFFEFF6FF),
                          image: FaIcon(
                            FontAwesomeIcons.locationDot,
                            size: 18,
                            color: Color(0xFF3B82F6),
                          ),
                          title: 'عناويني',
                          subtitle: 'إدارة عناوين التوصيل المحفوظة',
                          onTap: () {
                            context.pushRoute('/sm_my_addresses');
                          },
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.symmetric(
                            vertical: 16,
                          ),
                          child: Divider(
                            color: Color(0xFFF9FAFB),
                            thickness: 1,
                            height: 1,
                          ),
                        ),
                        SectionCard(
                          containerColor: Color(0xFFFEFCE8),
                          image: FaIcon(
                            FontAwesomeIcons.tags,
                            size: 18,
                            color: Color(0xFFEAB308),
                          ),
                          title: 'الحسومات',
                          subtitle: 'عرض الحسومات المتاحة',
                          onTap: () {
                            context.pushRoute('/sm_offers');
                          },
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.symmetric(
                            vertical: 16,
                          ),
                          child: Divider(
                            color: Color(0xFFF9FAFB),
                            thickness: 1,
                            height: 1,
                          ),
                        ),
                        SectionCard(
                          containerColor: Color(0x304CAF50),
                          image: FaIcon(
                            FontAwesomeIcons.cartShopping,
                            size: 18,
                            color: Color(0xFF4CAF50),
                          ),
                          title: 'قائمة التسوق',
                          subtitle: 'يمكنك إضافة قائمة تسوق لسرعة وسهولة الطلب',
                          onTap: () {
                            context.pushRoute('/sm_shopping_list');
                          },
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.symmetric(
                            vertical: 16,
                          ),
                          child: Divider(
                            color: Color(0xFFF9FAFB),
                            thickness: 1,
                            height: 1,
                          ),
                        ),
                        SectionCard(
                          containerColor: Color(0xFFFEF2F2),
                          image: FaIcon(
                            FontAwesomeIcons.solidHeart,
                            size: 18,
                            color: Color(0xFFEF4444),
                          ),
                          title: 'المفضلة',
                          subtitle: 'المطاعم والوجبات المفضلة',
                          onTap: () {
                            context.pushRoute('/sm_favorite');
                          },
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.symmetric(
                            vertical: 16,
                          ),
                          child: Divider(color: context.surface, thickness: .5),
                        ),
                        SectionCard(
                          containerColor: Color(0xFFFAF5FF),
                          image: FaIcon(
                            FontAwesomeIcons.solidBell,
                            size: 18,
                            color: Color(0xFFA855F7),
                          ),
                          title: 'الإشعارات',
                          subtitle: 'إشعارات الطلبات والعروض',
                          count: 3,
                          onTap: () {
                            context.pushRoute('/sm_notification');
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  SectionTitle(title: 'الدعم والمساعدة'),
                  SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: AppColors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x0F000000),
                          offset: Offset(0, 1),
                          blurRadius: 2,
                        ),
                        BoxShadow(
                          color: Color(0x1A000000),
                          offset: Offset(0, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    padding: EdgeInsetsDirectional.all(16),
                    child: Column(
                      children: [
                        SectionCard(
                          containerColor: Color(0xFFEEF2FF),
                          image: FaIcon(
                            FontAwesomeIcons.solidHeadphones,
                            size: 18,
                            color: Color(0xFF6366F1),
                          ),
                          title: 'الدعم والمساعدة',
                          subtitle: 'التواصل مع الدعم الفني',
                          onTap: () {
                            context.pushRoute('/offersmanagement');
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  InkWell(
                    onTap: () {
                      SharedPreferencesHelper.clearData();
                      context.pushRouteAndRemoveUntil('/login');
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xffEF4444).withAlpha(6),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Color(0xffEF4444).withAlpha(52),
                        ),
                      ),
                      padding: EdgeInsetsDirectional.only(top: 20, bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.arrowRightFromBracket,
                            size: 16,
                            color: Color(0xFFEF4444),
                          ),
                          SizedBox(width: 12),
                          AppText(
                            'تسجيل الخروج',
                            style: TextStyle(
                              color: Color(0xffEF4444),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              height: 24 / 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
