import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/themes/shared_platform_colors.dart';

/// A one-time introduction to the entire platform, not a cleaning tutorial.
/// This retains the legacy widget name for existing navigation/tests.
class CleaningFirstWelcome extends StatefulWidget {
  const CleaningFirstWelcome({
    super.key,
    required this.onStart,
    this.servicesSection = false,
  });

  final VoidCallback onStart;

  /// Reuse exactly the platform onboarding layout for the home-services area.
  final bool servicesSection;

  static const preferenceKey = 'platform_intro_seen_v2';
  static const servicesPreferenceKey = 'cleaning_services_intro_seen_v1';

  static Future<bool> shouldPresent() async {
    final preferences = await SharedPreferences.getInstance();
    return !(preferences.getBool(preferenceKey) ?? false);
  }

  static Future<bool> shouldPresentServices() async {
    final preferences = await SharedPreferences.getInstance();
    return !(preferences.getBool(servicesPreferenceKey) ?? false);
  }

  @override
  State<CleaningFirstWelcome> createState() => _CleaningFirstWelcomeState();
}

class _CleaningFirstWelcomeState extends State<CleaningFirstWelcome> {
  int _slide = 0;

  static const _slides = <({IconData icon, String category, String title, String description})>[
    (
      icon: Icons.auto_awesome_rounded,
      category: 'ع الندهة',
      title: 'أهلًا في ع الندهة!',
      description:
          'من ترتيبات البيت لطلبات الأكل والتسوق والتوصيل، كل اللي بتحتاجه صار بمكان واحد. خلّينا نسهّل عليك يومك.',
    ),
    (
      icon: Icons.cleaning_services_rounded,
      category: 'خدمات المنزل',
      title: 'بيتك مرتب، ووقتك إلك',
      description:
          'بدّك تنظيف لبيتك أو مساعدة لمناسبتك؟ اختَر نوع الخدمة والوقت المناسب وخلّينا نرتّب التفاصيل معك.',
    ),
    (
      icon: Icons.restaurant_rounded,
      category: 'المطاعم',
      title: 'وجبتك المفضلة أقرب',
      description:
          'اكتشف المطاعم واختَر اللي بيشهّيك، واطلب بسهولة من مكانك بدون ما تشغل بالك بالتفاصيل.',
    ),
    (
      icon: Icons.shopping_basket_rounded,
      category: 'السوبرماركت',
      title: 'احتياجات بيتك بدون مشوار',
      description:
          'من أساسيات المطبخ لاحتياجات كل يوم، تسوّق اللي ناقصك بخطوات واضحة وبالوقت اللي بناسبك.',
    ),
    (
      icon: Icons.local_shipping_rounded,
      category: 'التوصيل',
      title: 'أرسلها وخلي علينا المشوار',
      description:
          'عندك غرض بدك توصّله؟ قدّم طلب التوصيل وخلّي تفاصيله ومتابعته كلها بمكان واحد.',
    ),
    (
      icon: Icons.verified_user_outlined,
      category: 'اطلب براحة بال',
      title: 'تفاصيل واضحة من البداية',
      description:
          'شوف خياراتك قبل التأكيد، راجع تفاصيل الطلب وتابع حالته من التطبيق. أنت بتختار، وع الندهة بيسهّل المشوار.',
    ),
  ];

  static const _serviceSlides =
      <({IconData icon, String category, String title, String description})>[
        (
          icon: Icons.home_work_outlined,
          category: 'الخدمات المنزلية',
          title: 'بيتك علينا، ووقتك إلك',
          description:
              'من تنظيف البيت للتحضير للمناسبات، اختَر المساعدة اللي بتحتاجها وخلي ترتيب التفاصيل علينا.',
        ),
        (
          icon: Icons.meeting_room_outlined,
          category: 'تنظيف المنزل',
          title: 'كل غرفة إلها عنايتها',
          description:
              'حدّد الغرف وأحجامها، واختَر الحوسة للتنظيف المعتاد أو التعزيل لتنظيف أعمق. بتعرف شو رح ينظّف الفريق قبل ما تطلب.',
        ),
        (
          icon: Icons.auto_awesome_outlined,
          category: 'الخدمات المتخصصة',
          title: 'حتى التفاصيل الصغيرة إلها حل',
          description:
              'بدك غسيل سجاد أو كنب أو تنظيف نوافذ؟ أضف الخدمة المتوفرة حسب حاجتك وشوف تفاصيلها ضمن طلبك.',
        ),
        (
          icon: Icons.people_alt_outlined,
          category: 'فريق التنظيف',
          title: 'فريق يناسب حجم الشغل',
          description:
              'حدّد عدد العمال والموعد المناسب، وراجع المدة المتوقعة والتفاصيل قبل إرسال الطلب.',
        ),
        (
          icon: Icons.fact_check_outlined,
          category: 'قبل التأكيد',
          title: 'كل شيء واضح من البداية',
          description:
              'راجع العنوان والغرف والمواد والخدمات والسعر النهائي المعروض قبل تأكيد الحجز، وتابع طلبك من التطبيق.',
        ),
      ];

  Future<void> _finish() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(
      widget.servicesSection
          ? CleaningFirstWelcome.servicesPreferenceKey
          : CleaningFirstWelcome.preferenceKey,
      true,
    );
    if (!mounted) return;
    Navigator.of(context).pop();
    widget.onStart();
  }

  void _next() {
    final count = widget.servicesSection
        ? _serviceSlides.length
        : _slides.length;
    if (_slide < count - 1) {
      setState(() => _slide++);
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final slides = widget.servicesSection ? _serviceSlides : _slides;
    final slide = slides[_slide];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: SharedPlatformColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      size: 20,
                      color: SharedPlatformColors.primary,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'ع الندهة',
                      style: TextStyle(
                        color: SharedPlatformColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      key: const Key('platform_intro_skip'),
                      onPressed: _finish,
                      child: const Text('تخطي'),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Text(
                      widget.servicesSection
                          ? 'اكتشف الخدمات المنزلية'
                          : 'اكتشف عالم خدماتنا',
                      style: const TextStyle(
                        fontSize: 17,
                        color: SharedPlatformColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_slide + 1} من ${slides.length}',
                      key: const Key('platform_intro_step'),
                      style: const TextStyle(
                        fontSize: 13,
                        color: SharedPlatformColors.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    key: const Key('platform_intro_progress'),
                    value: (_slide + 1) / slides.length,
                    minHeight: 7,
                    backgroundColor: SharedPlatformColors.cleaningSoft,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      SharedPlatformColors.primary,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 240),
                        child: Column(
                          key: ValueKey(_slide),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 136,
                              height: 136,
                              decoration: BoxDecoration(
                                color: SharedPlatformColors.cleaningSoft,
                                borderRadius: BorderRadius.circular(34),
                              ),
                              child: Icon(
                                slide.icon,
                                size: 66,
                                color: SharedPlatformColors.primary,
                              ),
                            ),
                            const SizedBox(height: 28),
                            Text(
                              slide.category,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: SharedPlatformColors.cleaning,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              slide.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                height: 1.3,
                                color: SharedPlatformColors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              slide.description,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 17,
                                height: 1.75,
                                color: SharedPlatformColors.neutral,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 54,
                  child: FilledButton(
                    key: const Key('cleaning_intro_start'),
                    style: FilledButton.styleFrom(
                      backgroundColor: SharedPlatformColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _next,
                    child: Text(
                      _slide == slides.length - 1
                          ? (widget.servicesSection
                                ? 'يلا نحجز خدمة'
                                : 'يلا اكتشف الخدمات')
                          : 'التالي',
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 42,
                  child: _slide == 0
                      ? const SizedBox.shrink()
                      : TextButton(
                          onPressed: () => setState(() => _slide--),
                          child: const Text('السابق'),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
