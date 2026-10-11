import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import '../../../../core/themes/shared_platform_colors.dart';

/// Shared V7 screen header for customer routes; adapts accent to section.
class PersonalDetailsAppBar extends StatelessWidget {
  const PersonalDetailsAppBar({
    super.key,
    required this.title,
    this.backgroundColor,
    this.foregroundColor,
    this.section,
    this.trailing,
  });
  final String title;
  final Color? backgroundColor, foregroundColor;
  final String? section;
  final Widget? trailing;
  String? get _description {
    switch (title) {
      case 'التكامل الاجتماعي':
        return 'شارك طلبك مع أصدقائك.';
      case 'صندوق الحظ':
        return 'دعنا نساعدك في اختيار وجبتك.';
      case 'التصويت على الطلب':
        return 'اختاروا معاً ما يناسبكم.';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = SharedPlatformColors.sectionAccent(section);
    final ink = foregroundColor ?? accent;
    final description = _description;
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(12, 7, 16, 9),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        border: Border(
          bottom: BorderSide(color: accent.withValues(alpha: 0.42), width: 1.3),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'الرجوع',
            onPressed: () => context.pop(),
            style: IconButton.styleFrom(
              minimumSize: const Size(44, 44),
              foregroundColor: ink,
            ),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: ink,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    description,
                    maxLines: 2,
                    style: const TextStyle(
                      color: SharedPlatformColors.muted,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}
