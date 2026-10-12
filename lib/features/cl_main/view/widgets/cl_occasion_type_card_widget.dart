import 'package:flutter/material.dart';

import '../../../../core/auth/auth_gate.dart';
import '../../../../core/widgets/design_system/design_system.dart';

/// V6 occasion entry. Backend-configured event option and navigation preserved.
class ClOccasionTypeCardWidget extends StatelessWidget {
  const ClOccasionTypeCardWidget({
    required this.title,
    required this.imagePath,
    required this.onTap,
    super.key,
  });
  final String title;
  final String imagePath;
  final VoidCallback onTap;

  IconData get _occasionIcon {
    final key = '$title $imagePath'.toLowerCase();
    if (key.contains('عشاء') || key.contains('dinner')) {
      return Icons.dinner_dining_outlined;
    }
    if (key.contains('ميلاد') || key.contains('birthday')) {
      return Icons.cake_outlined;
    }
    if (key.contains('عزاء') ||
        key.contains('funeral') ||
        key.contains('aza')) {
      return Icons.volunteer_activism_outlined;
    }
    if (key.contains('تجمع') || key.contains('gathering')) {
      return Icons.groups_2_outlined;
    }
    return Icons.celebration_outlined;
  }

  String get _occasionDescription {
    final key = '$title $imagePath'.toLowerCase();
    if (key.contains('عشاء') || key.contains('dinner')) {
      return 'مساعدة في تجهيز المائدة والضيافة';
    }
    if (key.contains('ميلاد') || key.contains('birthday')) {
      return 'مساعدة في التحضير وتقديم الضيافة';
    }
    if (key.contains('عزاء') ||
        key.contains('funeral') ||
        key.contains('aza')) {
      return 'دعم هادئ لتنظيم الضيافة والمكان';
    }
    if (key.contains('تجمع') || key.contains('gathering')) {
      return 'تنظيم ومساعدة للمناسبات الكبيرة';
    }
    return 'حدد مهام المساعدة المناسبة لك';
  }

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(imagePath);
    final isRemote =
        uri != null && (uri.scheme == 'https' || uri.scheme == 'http');
    return Semantics(
      button: true,
      label: 'خدمة مناسبة: $title',
      child: AppSurfaceCard(
        section: AppSection.cleaning,
        onTap: () async {
          await AuthGate.requireAuth(
            context,
            onAuthenticated: () {
              if (!context.mounted) return;
              onTap();
            },
          );
        },
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 46,
                height: 46,
                color: AppSection.cleaning.soft,
                child: isRemote
                    ? Image.network(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            Icon(_occasionIcon, color: AlnadhaTokens.primary),
                      )
                    : Icon(_occasionIcon, color: AppSection.cleaning.ink),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AlnadhaTokens.sectionTitle),
                  const SizedBox(height: 3),
                  Text(_occasionDescription, style: AlnadhaTokens.caption),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_left_rounded,
              size: 20,
              color: AlnadhaTokens.muted,
            ),
          ],
        ),
      ),
    );
  }
}
