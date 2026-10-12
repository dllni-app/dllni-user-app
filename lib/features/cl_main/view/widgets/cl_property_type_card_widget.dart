import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/auth/auth_gate.dart';
import '../../../../core/widgets/design_system/design_system.dart';
import '../data/cl_main_route_args.dart';

/// V6 compact property entry retaining authenticated route and backend value.
class ClPropertyTypeCardWidget extends StatelessWidget {
  const ClPropertyTypeCardWidget({
    required this.title,
    required this.icon,
    required this.args,
    super.key,
  });
  final String title;
  final String icon;
  final ClMainHomeDescriptionArgs args;

  IconData get _icon => switch (args.propertyType) {
    'villa' => Icons.villa_outlined,
    'office' => Icons.business_outlined,
    'studio' => Icons.weekend_outlined,
    _ => Icons.apartment_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(icon);
    final isRemote =
        uri != null && (uri.scheme == 'https' || uri.scheme == 'http');
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
                child: isRemote
                    ? Image.network(
                        icon,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            Icon(_icon, color: AppSection.cleaning.ink),
                      )
                    : Icon(_icon, color: AppSection.cleaning.ink),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AlnadhaTokens.sectionTitle),
                  const SizedBox(height: 3),
                  const Text(
                    'حدّد الغرف والموعد في الخطوة التالية',
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
