import 'dart:convert';

import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/auth/auth_gate.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/core/realtime/cleaning_booking_pusher_service.dart';
import 'package:dllni_user_app/core/session/user_session_keys.dart';
import 'package:dllni_user_app/core/session/user_session_store.dart';
import 'package:dllni_user_app/core/widgets/support_whatsapp_launcher.dart';
import 'package:dllni_user_app/features/auth/data/models/login_response_model.dart';
import 'package:dllni_user_app/features/profile/domain/repository/profile_repo.dart';
import 'package:dllni_user_app/features/profile/view/manager/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../widgets/profile_app_bar.dart';
import '../widgets/profile_summary_card.dart';
import '../widgets/section_card.dart';
import '../widgets/section_title.dart';
import 'notifications_screen.dart';

LoggedInUserModel? _readLoggedInUser() {
  final raw = SharedPreferencesHelper.getData(
    key: UserSessionKeys.loggedInUser,
  );
  if (raw == null) return null;

  try {
    final decoded = jsonDecode('$raw');
    if (decoded is! Map) return null;
    return LoggedInUserModel.fromJson(Map<String, dynamic>.from(decoded));
  } catch (_) {
    return null;
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _navy = Color(0xFF1E2A78);
  static const _danger = Color(0xFFD92D20);

  late final ProfileBloc profileBloc = getIt<ProfileBloc>();
  bool _isDeletingAccount = false;

  LoggedInUserModel get _personalDetailsParams =>
      _readLoggedInUser() ?? LoggedInUserModel();

  Future<void> _openSupport() => launchSupportWhatsApp(context);

  Future<void> _clearLocalSession() async {
    await getIt<CleaningBookingPusherService>().disposeAllForSession();
    await SharedPreferencesHelper.clearData();
    await UserSessionStore.clear();
    AuthGate.clearPendingAction();
  }

  Future<void> _logout() async {
    await _clearLocalSession();
    if (!mounted) return;
    context.pushRouteAndRemoveUntil('/main');
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل تريد تسجيل الخروج من حسابك؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: _navy),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) await _logout();
  }

  Future<void> _deleteAccount() async {
    if (_isDeletingAccount) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف الحساب نهائياً'),
        content: const Text(
          'سيتم حذف بيانات حسابك الشخصية وإلغاء جميع جلسات تسجيل الدخول. '
          'قد يتم الاحتفاظ فقط بسجلات المعاملات التي يلزم الاحتفاظ بها '
          'لأسباب قانونية أو محاسبية بعد إزالة بياناتك الشخصية منها. '
          'لا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: _danger),
            child: const Text('حذف الحساب نهائياً'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isDeletingAccount = true);
    final result = await getIt<ProfileRepo>().deleteAccount();
    if (!mounted) return;

    await result.fold(
      (failure) async {
        if (!mounted) return;
        setState(() => _isDeletingAccount = false);
        AppToast.showToast(
          context: context,
          message: failure.message,
          type: ToastificationType.error,
        );
      },
      (_) async {
        await _clearLocalSession();
        if (!mounted) return;
        AppToast.showToast(
          context: context,
          message: 'تم حذف الحساب بنجاح',
          type: ToastificationType.success,
        );
        context.pushRouteAndRemoveUntil('/main');
      },
    );
  }

  Future<void> _openPersonalDetails() async {
    await context.pushRoute(
      '/personaldetails',
      arguments: _personalDetailsParams,
    );
    if (mounted) setState(() {});
  }

  void _openNotifications() {
    context.pushRoute(
      '/notifications',
      arguments: NotificationsScreenParams(profileBloc: profileBloc),
    );
  }

  Widget _menuGroup(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4E7EC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() => const Divider(height: 1, color: Color(0xFFEAECF0));

  Widget _guestProfile(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF7F8FA),
      child: SafeArea(
        child: Column(
          children: [
            const ProfileAppBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFE4E7EC)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE9F9FA),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_outline_rounded,
                            size: 34,
                            color: _navy,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'أهلاً بك',
                          style: TextStyle(
                            color: Color(0xFF172033),
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'سجّل الدخول لإدارة حجوزات التنظيف وعناوين الخدمة والإشعارات من مكان واحد.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF667085),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 18),
                        FilledButton(
                          onPressed: () async {
                            await AuthGate.requireAuth(
                              context,
                              message: '',
                              onAuthenticated: () {
                                if (mounted) setState(() {});
                              },
                            );
                          },
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            backgroundColor: _navy,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'تسجيل الدخول',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => context.pushRoute('/register'),
                          child: const Text('إنشاء حساب جديد'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SectionTitle(title: 'المساعدة والمعلومات'),
                  const SizedBox(height: 10),
                  _menuGroup([
                    SectionCard(
                      containerColor: const Color(0xFFE9F9FA),
                      image: const Icon(
                        Icons.support_agent_rounded,
                        color: Color(0xFF0F8E98),
                      ),
                      title: 'الدعم والمساعدة',
                      subtitle: 'تواصل مع فريق الدعم عبر واتساب',
                      onTap: _openSupport,
                    ),
                    _divider(),
                    SectionCard(
                      containerColor: const Color(0xFFF2F4FF),
                      image: const Icon(
                        Icons.description_outlined,
                        color: _navy,
                      ),
                      title: 'الشروط والخصوصية',
                      subtitle: 'راجع الروابط القانونية الرسمية للتطبيق',
                      onTap: () => context.pushRoute('/termsAndConditions'),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthGate.isAuthenticated) return _guestProfile(context);

    final personalDetails = _personalDetailsParams;
    return ColoredBox(
      color: const Color(0xFFF7F8FA),
      child: SafeArea(
        child: Column(
          children: [
            const ProfileAppBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                children: [
                  ProfileSummaryCard(
                    params: personalDetails,
                    onEditTap: _openPersonalDetails,
                  ),
                  const SizedBox(height: 20),
                  SectionTitle(title: 'إدارة الحساب'),
                  const SizedBox(height: 10),
                  _menuGroup([
                    SectionCard(
                      containerColor: const Color(0xFFF2F4FF),
                      image: const Icon(
                        Icons.person_outline_rounded,
                        color: _navy,
                      ),
                      title: 'البيانات الشخصية',
                      subtitle: 'الاسم والصورة ورقم الهاتف وكلمة المرور',
                      onTap: _openPersonalDetails,
                    ),
                    _divider(),
                    SectionCard(
                      containerColor: const Color(0xFFE9F9FA),
                      image: const Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFF0F8E98),
                      ),
                      title: 'العناوين المحفوظة',
                      subtitle: 'أدر عناوين خدمة التنظيف والعنوان الافتراضي',
                      onTap: () =>
                          context.pushRoute('/myaddresses', arguments: false),
                    ),
                    _divider(),
                    SectionCard(
                      containerColor: const Color(0xFFFFF7E6),
                      image: const Icon(
                        Icons.notifications_none_rounded,
                        color: Color(0xFFB54708),
                      ),
                      title: 'الإشعارات',
                      subtitle: 'تابع تحديثات الحجوزات والتنبيهات المهمة',
                      onTap: _openNotifications,
                    ),
                  ]),
                  const SizedBox(height: 20),
                  SectionTitle(title: 'المساعدة والمعلومات'),
                  const SizedBox(height: 10),
                  _menuGroup([
                    SectionCard(
                      containerColor: const Color(0xFFE9F9FA),
                      image: const Icon(
                        Icons.support_agent_rounded,
                        color: Color(0xFF0F8E98),
                      ),
                      title: 'الدعم والمساعدة',
                      subtitle: 'تواصل مع فريق الدعم عبر واتساب',
                      onTap: _openSupport,
                    ),
                    _divider(),
                    SectionCard(
                      containerColor: const Color(0xFFF2F4FF),
                      image: const Icon(
                        Icons.description_outlined,
                        color: _navy,
                      ),
                      title: 'الشروط والخصوصية',
                      subtitle: 'راجع الروابط القانونية الرسمية للتطبيق',
                      onTap: () => context.pushRoute('/termsAndConditions'),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  SectionTitle(title: 'إجراءات الحساب'),
                  const SizedBox(height: 10),
                  _menuGroup([
                    SectionCard(
                      containerColor: const Color(0xFFFFF1F0),
                      image: const Icon(Icons.logout_rounded, color: _danger),
                      title: 'تسجيل الخروج',
                      subtitle: 'إنهاء جلسة حسابك على هذا الجهاز',
                      onTap: _confirmLogout,
                    ),
                    _divider(),
                    SectionCard(
                      containerColor: const Color(0xFFFFF1F0),
                      image: _isDeletingAccount
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _danger,
                              ),
                            )
                          : const Icon(
                              Icons.delete_forever_outlined,
                              color: _danger,
                            ),
                      title: _isDeletingAccount
                          ? 'جاري حذف الحساب...'
                          : 'حذف الحساب',
                      subtitle: 'حذف بيانات الحساب نهائياً',
                      onTap: _isDeletingAccount ? () {} : _deleteAccount,
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
