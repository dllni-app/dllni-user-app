import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../generated/assets.dart';
import 'personal_details_screen.dart';
import '../widgets/profile_app_bar.dart';
import '../widgets/profile_summary_card.dart';
import '../widgets/section_card.dart';
import '../widgets/section_title.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const PersonalDetailsParams _personalDetailsParams = PersonalDetailsParams(
    name: 'مطعم البيت الحلبي',
    phoneLocal: '987654321',
    dialCode: '+963',
    isPhoneVerified: true,
    email: 'ahmed.m@example.com',
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          ProfileAppBar(),
          SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsetsDirectional.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ProfileSummaryCard(
                    params: _personalDetailsParams,
                    onEditTap: () {
                      context.pushRoute('/personaldetails', arguments: _personalDetailsParams);
                    },
                  ),
                  SizedBox(height: 16),
                  SectionTitle(title: 'إدارة الحساب'),
                  SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: context.onPrimaryContainer,
                      border: Border.all(color: Color(0xffF3F4F6), width: 1),
                      boxShadow: [BoxShadow(color: Colors.black.withAlpha(6), offset: Offset(0, 2), blurRadius: 10)],
                    ),
                    padding: EdgeInsetsDirectional.all(16),
                    child: Column(
                      children: [
                        SectionCard(
                          containerColor: Color(0xff3B82F6).withAlpha(25),
                          image: Icon(Icons.location_on, size: 18, color: Color(0xff3B82F6)),
                          title: 'عناويني',
                          subtitle: 'إدارة عناوين التوصيل المحفوظة',
                          onTap: () {
                            context.pushRoute('/myaddresses', arguments: false);
                          },
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.symmetric(vertical: 16),
                          child: Divider(color: context.surface, thickness: .5),
                        ),
                        SectionCard(
                          containerColor: Color(0xffEAB308).withAlpha(25),
                          image: Assets.images.rsProfileCoupon.svg(width: 18, color: Color(0xffEAB308)),
                          title: 'الكوبونات',
                          subtitle: 'عرض الكوبونات المتاحة',
                          onTap: () {
                            context.pushRoute('/coupons');
                          },
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.symmetric(vertical: 16),
                          child: Divider(color: context.surface, thickness: .5),
                        ),
                        SectionCard(
                          containerColor: Color(0xffA855F7).withAlpha(25),
                          image: Icon(Icons.notifications, size: 18, color: Color(0xffA855F7)),
                          title: 'الإشعارات',
                          subtitle: 'إشعارات الطلبات والعروض',
                          onTap: () {
                            context.pushRoute('/notifications');
                          },
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.symmetric(vertical: 16),
                          child: Divider(color: context.surface, thickness: .5),
                        ),
                        SectionCard(
                          containerColor: Color(0xff14B8A6).withAlpha(25),
                          image: Icon(Icons.casino_outlined, size: 18, color: Color(0xff14B8A6)),
                          title: 'صندوق الحظ',
                          subtitle: 'خصص البحث واحصل على اقتراحات جاهزة',
                          onTap: () {
                            context.pushRoute('/luckyboxsetup');
                          },
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.symmetric(vertical: 16),
                          child: Divider(color: context.surface, thickness: .5),
                        ),
                        SectionCard(
                          containerColor: Color(0xffFF7A00).withAlpha(25),
                          image: Icon(Icons.poll_outlined, size: 18, color: Color(0xffFF7A00)),
                          title: 'التصويت على الطلب',
                          subtitle: 'أنشئ تصويتاً وشارك الاختيار',
                          onTap: () {
                            context.pushRoute('/ordervoting');
                          },
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.symmetric(vertical: 16),
                          child: Divider(color: context.surface, thickness: .5),
                        ),
                        SectionCard(
                          containerColor: Color(0xFF22C55E).withAlpha(35),
                          image: FaIcon(FontAwesomeIcons.basketShopping, size: 16, color: Color(0xFF22C55E)),
                          title: 'قائمة التسوق',
                          subtitle: 'يمكنك إضافة قائمة تسوق لسرعة وسهولة الطلب',
                          onTap: () {
                            context.pushRoute('/shopping_list');
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
                      borderRadius: BorderRadius.circular(24),
                      color: context.onPrimaryContainer,
                      border: Border.all(color: Color(0xffF3F4F6), width: 1),
                      boxShadow: [BoxShadow(color: Colors.black.withAlpha(6), offset: Offset(0, 2), blurRadius: 10)],
                    ),
                    padding: EdgeInsetsDirectional.all(16),
                    child: Column(
                      children: [
                        SectionCard(
                          containerColor: Color(0xff6366F1).withAlpha(25),
                          image: Icon(Icons.headphones, size: 18, color: Color(0xff6366F1)),
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
                        border: Border.all(color: Color(0xffEF4444).withAlpha(52)),
                      ),
                      padding: EdgeInsetsDirectional.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(color: Color(0xffEF4444).withAlpha(25), borderRadius: BorderRadius.circular(16)),
                            padding: EdgeInsetsDirectional.all(13),
                            child: Icon(Icons.logout_rounded, color: Color(0xffEF4444)),
                          ),
                          SizedBox(width: 12),
                          AppText.bodyMedium('تسجيل الخروج', color: Color(0xffEF4444), fontWeight: FontWeight.bold),
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
