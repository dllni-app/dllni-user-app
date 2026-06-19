import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/core/realtime/cleaning_booking_pusher_service.dart';
import 'package:dllni_user_app/core/session/user_session_store.dart';
import 'package:dllni_user_app/features/profile/view/manager/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../generated/assets.dart';
import '../../../auth/data/models/login_response_model.dart';
import '../widgets/profile_app_bar.dart';
import '../widgets/profile_summary_card.dart';
import '../widgets/section_card.dart';
import '../widgets/section_title.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileBloc profileBloc = getIt<ProfileBloc>();

  @override
  void initState() {
    super.initState();
    UserSessionStore.reload();
  }

  Future<void> _openPersonalDetails(LoggedInUserModel currentUser) async {
    await context.pushRoute<bool>(
      '/personaldetails',
      arguments: currentUser,
    );
    UserSessionStore.reload();
    if (mounted) setState(() {});
  }

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
                  ValueListenableBuilder<LoggedInUserModel?>(
                    valueListenable: UserSessionStore.userNotifier,
                    builder: (context, user, _) {
                      final currentUser =
                          user ?? UserSessionStore.read() ?? LoggedInUserModel();
                      return ProfileSummaryCard(
                        params: currentUser,
                        onEditTap: () => _openPersonalDetails(currentUser),
                      );
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(6),
                          offset: Offset(0, 2),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    padding: EdgeInsetsDirectional.all(16),
                    child: Column(
                      children: [
                        SectionCard(
                          containerColor: Color(0xff1E2A78).withAlpha(25),
                          image: Icon(
                            Icons.delivery_dining_rounded,
                            size: 18,
                            color: Color(0xff1E2A78),
                          ),
                          title: 'طلبات التوصيل',
                          subtitle: 'تتبع حالة توصيل الطلبات',
                          onTap: () {
                            context.pushRoute('/delivery/orders');
                          },
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.symmetric(
                            vertical: 16,
                          ),
                          child: Divider(color: context.surface, thickness: .5),
                        ),
                        SectionCard(
                          containerColor: Color(0xff3B82F6).withAlpha(25),
                          image: Icon(
                            Icons.location_on,
                            size: 18,
                            color: Color(0xff3B82F6),
                          ),
                          title: 'عناويني',
                          subtitle: 'إدارة عناوين التوصيل المحفوظة',
                          onTap: () {
                            context.pushRoute('/myaddresses', arguments: false);
                          },
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.symmetric(
                            vertical: 16,
                          ),
                          child: Divider(color: context.surface, thickness: .5),
                        ),
                        SectionCard(
                          containerColor: Color(0xffEAB308).withAlpha(25),
                          image: Assets.images.rsProfileCoupon.svg(
                            width: 18,
                            color: Color(0xffEAB308),
                          ),
                          title: 'الكوبونات',
                          subtitle: 'عرض الكوبونات المتاحة',
                          onTap: () {
                            context.pushRoute('/coupons');
                          },
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.symmetric(
                            vertical: 16,
                          ),
                          child: Divider(color: context.surface, thickness: .5),
                        ),
                        SectionCard(
                          containerColor: Color(0xffA855F7).withAlpha(25),
                          image: Icon(
                            Icons.notifications,
                            size: 18,
                            color: Color(0xffA855F7),
                          ),
                          title: 'الإشعارات',
                          subtitle: 'إشعارات الطلبات والعروض',
                          onTap: () {
                            context.pushRoute('/notifications');
                          },
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.symmetric(
                            vertical: 16,
                          ),
                          child: Divider(color: context.surface, thickness: .5),
                        ),
                        SectionCard(
                          containerColor: Color(0xFF22C55E).withAlpha(35),
                          image: FaIcon(
                            FontAwesomeIcons.basketShopping,
                            size: 16,
                            color: Color(0xFF22C55E),
                          ),
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(6),
                          offset: Offset(0, 2),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    padding: EdgeInsetsDirectional.all(16),
                    child: Column(
                      children: [
                        SectionCard(
                          containerColor: Color(0xff6366F1).withAlpha(25),
                          image: Icon(
                            Icons.headphones,
                            size: 18,
                            color: Color(0xff6366F1),
                          ),
                          title: 'الدعم والمساعدة',
                          subtitle: 'التواصل مع الدعم الفني',
                          onTap: () {
                            launchUrl(
                              Uri.parse('https://wa.me/message/XJOZBNT3VS5SJ1'),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      await getIt<CleaningBookingPusherService>()
                          .disposeAllForSession();
                      await SharedPreferencesHelper.clearData();
                      UserSessionStore.reload();
                      if (!context.mounted) return;
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
                      padding: EdgeInsetsDirectional.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xffEF4444).withAlpha(25),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: EdgeInsetsDirectional.all(13),
                            child: Icon(
                              Icons.logout_rounded,
                              color: Color(0xffEF4444),
                            ),
                          ),
                          SizedBox(width: 12),
                          AppText.bodyMedium(
                            'تسجيل الخروج',
                            color: Color(0xffEF4444),
                            fontWeight: FontWeight.bold,
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
