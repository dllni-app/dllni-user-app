import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/shared_platform_colors.dart';

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
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? section;
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
    final description = _featureDescription;
    final background =
        backgroundColor ?? SharedPlatformColors.sectionAccent(section);
    final foreground = foregroundColor ?? Colors.white;

    return Container(
      width: double.infinity,
      padding: EdgeInsetsDirectional.fromSTEB(
        14,
        12,
        14,
        description == null ? 14 : 12,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: description == null
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => context.pop(),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withAlpha(28),
              foregroundColor: foreground,
              minimumSize: const Size(44, 44),
            ),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: description == null ? 8 : 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: foreground.withAlpha(205),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}
