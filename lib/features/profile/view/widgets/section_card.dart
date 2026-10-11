import 'package:flutter/material.dart';
import '../../../../core/themes/shared_platform_colors.dart';
import '../../../../core/themes/v7_artwork.dart';

/// One simple, accessible Pen V7 account action row.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.containerColor,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final Color containerColor;
  final Widget image;
  final String title, subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: title,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 65),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
            child: Row(
              children: [
                Container(
                  width: 43,
                  height: 43,
                  padding: const EdgeInsets.all(4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: switch (title) {
                    'العناوين المحفوظة' => Image.asset(V7Artwork.address),
                    'الدعم والمساعدة' => Image.asset(V7Artwork.support),
                    _ => image,
                  },
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: SharedPlatformColors.ink,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: SharedPlatformColors.muted,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_left_rounded,
                  size: 20,
                  color: SharedPlatformColors.muted,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
