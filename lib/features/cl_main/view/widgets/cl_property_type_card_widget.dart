import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/auth/auth_gate.dart';
import '../../../../core/themes/shared_platform_colors.dart';
import '../../../../core/themes/v7_artwork.dart';
import '../data/cl_main_route_args.dart';

/// Compact V7 property choice. Visuals are decorative; the actual property type
/// and the authenticated booking route are not changed by this presentation.
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

  bool get _isNetworkImage {
    final uri = Uri.tryParse(icon);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  Widget _artwork() {
    final fallback = V7Artwork.property(args.propertyType);
    if (_isNetworkImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          icon,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => V7ArtTile(asset: fallback, size: 80),
        ),
      );
    }
    return V7ArtTile(asset: fallback, size: 80);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'اختيار $title',
      child: Material(
        color: SharedPlatformColors.surface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () async {
            await AuthGate.requireAuth(
              context,
              onAuthenticated: () {
                if (!context.mounted) return;
                context.pushRoute('/clmainhomedescription', arguments: args);
              },
            );
          },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            constraints: const BoxConstraints(minHeight: 112),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: SharedPlatformColors.border),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                _artwork(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText.bodyLarge(
                        title,
                        textAlign: TextAlign.start,
                        fontWeight: FontWeight.w800,
                        color: SharedPlatformColors.ink,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'حدّد تفاصيل المكان وموعد التنظيف',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: SharedPlatformColors.muted,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 7),
                const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: SharedPlatformColors.cleaningInk,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
