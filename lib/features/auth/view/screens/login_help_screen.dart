import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/widgets/support_whatsapp_launcher.dart';
import 'package:flutter/material.dart';

class LoginHelpScreen extends StatelessWidget {
  const LoginHelpScreen({super.key});

  static const _navy = Color(0xFF1E2A78);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: SafeArea(
          child: Column(
            children: [
              _LoginHelpHeader(onBack: () => Navigator.of(context).pop()),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF0FA),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'كيف نقدر نساعدك؟',
                            style: TextStyle(
                              color: _navy,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'اختر المشكلة الأقرب لحالتك وسنوجّهك للخطوة المناسبة.',
                            style: TextStyle(
                              color: Color(0xFF66708C),
                              fontSize: 12,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _HelpOption(
                      icon: Icons.lock_reset_rounded,
                      title: 'نسيت كلمة المرور',
                      subtitle: 'استعد حسابك باستخدام رقم الجوال.',
                      onTap: () => context.pushRoute('/account-recovery'),
                    ),
                    const SizedBox(height: 10),
                    _HelpOption(
                      icon: Icons.sms_outlined,
                      title: 'لم يصل رمز التحقق',
                      subtitle: 'تحقق من الرقم أو اطلب رمزاً جديداً.',
                      onTap: () => context.pushRoute('/account-recovery'),
                    ),
                    const SizedBox(height: 10),
                    _HelpOption(
                      icon: Icons.phone_android_rounded,
                      title: 'رقمي تغيّر',
                      subtitle: 'تواصل مع الدعم لتحديث وسيلة الدخول.',
                      onTap: () => launchSupportWhatsApp(context),
                    ),
                    const SizedBox(height: 10),
                    _HelpOption(
                      icon: Icons.person_off_outlined,
                      title: 'تم إلغاء تفعيل حسابي',
                      subtitle: 'تعرّف على الخطوات المتاحة لإعادة التفعيل.',
                      onTap: () => launchSupportWhatsApp(context),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9F9FA),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.support_agent_rounded,
                            color: Color(0xFF0F8E98),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ما لقيت الحل؟',
                                  style: TextStyle(
                                    color: Color(0xFF0F8E98),
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'تواصل مع فريق الدعم عبر واتساب.',
                                  style: TextStyle(
                                    color: Color(0xFF52777A),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => launchSupportWhatsApp(context),
                            child: const Text(
                              'تواصل',
                              style: TextStyle(
                                color: Color(0xFF0F8E98),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginHelpHeader extends StatelessWidget {
  const _LoginHelpHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: _LoginHelpScreenColors.border),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_forward_rounded,
              color: _LoginHelpScreenColors.navy,
            ),
          ),
          const SizedBox(width: 6),
          const Expanded(
            child: Text(
              'مساعدة تسجيل الدخول',
              style: TextStyle(
                color: _LoginHelpScreenColors.ink,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpOption extends StatelessWidget {
  const _HelpOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 82),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: _LoginHelpScreenColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF0FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _LoginHelpScreenColors.navy, size: 21),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _LoginHelpScreenColors.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _LoginHelpScreenColors.muted,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 15,
                color: Color(0xFF98A2B3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

abstract final class _LoginHelpScreenColors {
  static const navy = Color(0xFF1E2A78);
  static const ink = Color(0xFF172033);
  static const muted = Color(0xFF667085);
  static const border = Color(0xFFE4E7EC);
}
