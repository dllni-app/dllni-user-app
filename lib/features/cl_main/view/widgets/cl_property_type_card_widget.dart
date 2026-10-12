import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/auth/auth_gate.dart';
import '../../../../core/widgets/design_system/design_system.dart';
import '../data/cl_main_route_args.dart';
import '../helpers/cleaning_category_icon.dart';

/// V6 compact property entry retaining authenticated route and backend value.
class ClPropertyTypeCardWidget extends StatelessWidget {
  const ClPropertyTypeCardWidget({
    required this.title,
    required this.icon,
    required this.args,
    this.description,
    super.key,
  });
  final String title;
  final String icon;
  final ClMainHomeDescriptionArgs args;
  final String? description;

  IconData get _icon =>
      cleaningCategoryIcon(icon.isEmpty ? args.propertyType : icon);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'اختيار $title',
      child: AppSurfaceCard(
        section: AppSection.cleaning,
        onTap: () async {
          await AuthGate.requireAuth(
            context,
            onAuthenticated: () {
              if (!context.mounted) return;
              context.pushRoute('/clmainhomedescription', arguments: args);
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
                child: Icon(_icon, color: AppSection.cleaning.ink),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AlnadhaTokens.sectionTitle),
                  const SizedBox(height: 3),
                  Text(
                    description?.trim().isNotEmpty == true
                        ? description!.trim()
                        : 'حدّد الغرف والموعد في الخطوة التالية',
                    style: AlnadhaTokens.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
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
