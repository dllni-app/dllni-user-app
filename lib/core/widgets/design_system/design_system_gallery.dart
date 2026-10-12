import 'package:flutter/material.dart';
import 'design_system.dart';

/// A fixture-driven gallery for visual/golden QA. Not registered as a user route.
class DesignSystemGallery extends StatefulWidget {
  const DesignSystemGallery({super.key});
  @override
  State<DesignSystemGallery> createState() => _DesignSystemGalleryState();
}

class _DesignSystemGalleryState extends State<DesignSystemGallery> {
  int count = 2;
  bool selected = true;
  int tab = 0;

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: AlnadhaTokens.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const AppSectionHeading(
              title: 'مكتبة مكونات ع الندهة',
              description: 'مرجع V6 UX Refined — أمثلة عرض فقط',
            ),
            const SizedBox(height: 16),
            const AppStatusBadge(
              label: 'جاري تأكيد طلبك',
              intent: AppStatusIntent.pending,
            ),
            const SizedBox(height: 16),
            const AppOrderCard(
              title: 'تنظيف شقة',
              reference: 'CLN-USER-2026',
              status: 'تم قبول الطلب',
              scheduleLabel: 'الثلاثاء، 20 أكتوبر',
              amountLabel: '75,000 ل.س',
              section: AppSection.cleaning,
              statusIntent: AppStatusIntent.success,
            ),
            const SizedBox(height: 16),
            AppChoiceTile(
              title: 'التنظيف العادي',
              description: 'تنظيف المنزل ضمن المهام المحددة',
              selected: selected,
              onTap: () => setState(() => selected = !selected),
            ),
            const SizedBox(height: 12),
            AppCounter(
              label: 'غرف النوم',
              value: count,
              maximum: 6,
              onChanged: (v) => setState(() => count = v),
            ),
            const SizedBox(height: 16),
            const AppStepProgress(current: 2, total: 6),
            const SizedBox(height: 16),
            const AppPriceSummary(
              lines: [
                AppPriceLine(label: 'الخدمة', formattedAmount: '70,000 ل.س'),
              ],
              totalFormatted: '70,000 ل.س',
              provisional: true,
              note: 'يؤكد النظام السعر النهائي قبل إرسال الطلب.',
            ),
            const SizedBox(height: 12),
            const AppErrorState(message: 'تحقق من الاتصال ثم أعد المحاولة'),
            const SizedBox(height: 12),
            const AppSkeleton(),
            const SizedBox(height: 16),
            AppActionButton(label: 'متابعة', onPressed: () {}),
            const SizedBox(height: 8),
            AppActionButton(
              label: 'اختيار خدمة',
              variant: AppActionVariant.secondary,
              section: AppSection.cleaning,
              onPressed: () {},
            ),
            const SizedBox(height: 8),
            AppActionButton(
              label: 'التفاصيل',
              variant: AppActionVariant.outlined,
              onPressed: () {},
            ),
            const SizedBox(height: 8),
            const AppActionButton(label: 'غير متاح', onPressed: null),
            const SizedBox(height: 8),
            AppActionButton(
              label: 'جارٍ الإرسال',
              loading: true,
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            const AppFormTextField(label: 'الاسم', hint: 'الاسم الكامل'),
            const SizedBox(height: 12),
            const AppStatusTimeline(
              entries: [
                AppTimelineEntry(title: 'تم استلام الطلب', completed: true),
                AppTimelineEntry(title: 'بانتظار تأكيد العامل', current: true),
                AppTimelineEntry(title: 'بدء الخدمة'),
              ],
            ),
            const SizedBox(height: 12),
            AppActionButton(
              label: 'إلغاء الطلب',
              variant: AppActionVariant.danger,
              onPressed: () {},
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        destinations: const [
          AppNavDestination(label: 'الرئيسية', icon: Icons.home_outlined),
          AppNavDestination(label: 'طلباتي', icon: Icons.receipt_outlined),
          AppNavDestination(label: 'حسابي', icon: Icons.person_outline),
        ],
        selectedIndex: tab,
        onSelect: (v) => setState(() => tab = v),
      ),
    ),
  );
}
