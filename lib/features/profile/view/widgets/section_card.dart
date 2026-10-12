import 'package:flutter/material.dart';
import '../../../../core/widgets/design_system/design_system.dart';

/// Shared V6 account navigation row; the caller owns its action.
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
    label: '$title، $subtitle',
    child: Material(
      color: AlnadhaTokens.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 72),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(8, 12, 8, 12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: IconTheme(
                    data: const IconThemeData(
                      color: AlnadhaTokens.primary,
                      size: 25,
                    ),
                    child: image,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AlnadhaTokens.body.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: AlnadhaTokens.caption,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_left_rounded,
                  size: 23,
                  color: AlnadhaTokens.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
