import 'package:flutter/material.dart';
import '../../../../core/widgets/design_system/design_system.dart';

/// Pencil booking-flow header using the existing cleaning section palette.
/// The selection and backend workflow remain owned by the parent screen.
class ClBookingPencilHeader extends StatelessWidget {
  const ClBookingPencilHeader({
    super.key,
    required this.step,
    required this.title,
    required this.subtitle,
  });

  final int step;
  final String title;
  final String subtitle;

  static const _labels = <String>[
    'الغرف',
    'المقاسات',
    'التنظيف',
    'المواد',
    'الإضافات',
    'الموعد',
    'المراجعة',
  ];

  @override
  Widget build(BuildContext context) {
    final current = step.clamp(0, _labels.length - 1);
    final color = AppSection.cleaning.accent;
    return Semantics(
      label: 'الخطوة ${current + 1} من 7: $title',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'احجز خدمة تنظيف',
                  style: AlnadhaTokens.caption.copyWith(
                    color: AppSection.cleaning.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${current + 1} / 7',
                textDirection: TextDirection.ltr,
                style: AlnadhaTokens.caption.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              _labels.length,
              (i) => Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                    end: i == _labels.length - 1 ? 0 : 4,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: i <= current ? color : AlnadhaTokens.border,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _labels[current],
            style: AlnadhaTokens.caption.copyWith(
              color: AppSection.cleaning.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          Text(title, style: AlnadhaTokens.title),
          const SizedBox(height: 6),
          Text(subtitle, style: AlnadhaTokens.caption),
        ],
      ),
    );
  }
}

/// Shared top navigation for every cleaning-booking step, including those
/// implemented in separate route widgets. Exit is handled by the caller's
/// confirmation dialog; Previous is the sticky bottom action.
class ClBookingTopBar extends StatelessWidget implements PreferredSizeWidget {
  const ClBookingTopBar({
    super.key,
    required this.onExit,
    this.exitEnabled = true,
  });

  final VoidCallback onExit;
  final bool exitEnabled;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
    title: const Text('حجز تنظيف'),
    backgroundColor: AlnadhaTokens.background,
    elevation: 0,
    scrolledUnderElevation: 0,
    surfaceTintColor: Colors.transparent,
    automaticallyImplyLeading: false,
    leading: IconButton(
      tooltip: 'الخروج من الطلب',
      icon: const Icon(Icons.close_rounded),
      onPressed: exitEnabled ? onExit : null,
    ),
  );
}
