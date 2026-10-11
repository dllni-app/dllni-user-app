import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/auth/auth_gate.dart';
import '../../../../core/themes/shared_platform_colors.dart';
import '../../../../core/themes/v7_artwork.dart';

/// Authentic configured events stay intact; only their visual entry cards
/// change to match V7. Unverified server images fall back to local illustration.
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

  bool get _isNetworkImage {
    final uri = Uri.tryParse(imagePath);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  Widget _image() {
    if (_isNetworkImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          imagePath,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) =>
              V7ArtTile(asset: V7Artwork.cleaningMode('event'), size: 80),
        ),
      );
    }
    return V7ArtTile(asset: V7Artwork.cleaningMode('event'), size: 80);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'خدمة مناسبة: $title',
      child: Material(
        color: SharedPlatformColors.surface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () async {
            await AuthGate.requireAuth(
              context,
              onAuthenticated: () {
                if (!context.mounted) return;
                onTap();
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
                _image(),
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'اختَر الخدمة والمدة المناسبة',
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
