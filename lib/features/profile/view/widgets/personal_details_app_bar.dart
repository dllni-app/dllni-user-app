import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class PersonalDetailsAppBar extends StatelessWidget {
  const PersonalDetailsAppBar({
    super.key,
    required this.title,
    this.backgroundColor,
    this.foregroundColor,
    this.trailing,
  });

  final String title;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Widget? trailing;

  String? get _featureDescription {
    switch (title) {
      case 'التكامل الاجتماعي':
        return 'أنشئ طلبًا جماعيًا من مطعم واحد وشارك الجلسة مع أصدقائك ليضيف كل شخص اختياراته.';
      case 'صندوق الحظ':
        return 'حدّد عدد الأشخاص والميزانية والتفضيلات، وسنقترح لك خيارات مطاعم ووجبات مناسبة تلقائيًا.';
      case 'التصويت على الطلب':
        return 'اختر عدة وجبات، أنشئ تصويتًا وشاركه مع أصدقائك لتختاروا الوجبة المناسبة معًا.';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolvedBackgroundColor = backgroundColor ?? context.onPrimary;
    final resolvedForegroundColor = foregroundColor ?? context.primary;
    final featureDescription = _featureDescription;

    return Container(
      decoration: BoxDecoration(
        color: resolvedBackgroundColor,
        border: Border(
          bottom: BorderSide(color: context.primaryContainer, width: 3),
        ),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(27),
            offset: Offset(0, -2),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      width: context.width,
      height: featureDescription == null ? 70 : 104,
      padding: EdgeInsetsDirectional.symmetric(horizontal: 16),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => context.pop(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: context.onPrimary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xffE5E7EB)),
              ),
              child: Icon(Icons.arrow_back, color: resolvedForegroundColor),
            ),
          ),
          SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.headlineMedium(
                  title,
                  color: resolvedForegroundColor,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.start,
                ),
                if (featureDescription != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    featureDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      color: Color(0xff6B7280),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.45,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
