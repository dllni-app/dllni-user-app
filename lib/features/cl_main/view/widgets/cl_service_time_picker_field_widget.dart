import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/shared_platform_colors.dart';

class ClServiceTimePickerFieldWidget extends StatelessWidget {
  const ClServiceTimePickerFieldWidget({
    required this.title,
    required this.controller,
    this.onTap,
    super.key,
  });

  final String title;
  final TextEditingController controller;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.bodyMedium(
          title,
          color: const Color(0xFF656B78),
          fontWeight: FontWeight.w700,
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            final rawValue = value.text.trim();
            final separatorIndex = rawValue.lastIndexOf(' ');
            final time = separatorIndex > 0
                ? rawValue.substring(0, separatorIndex).trim()
                : rawValue;
            final period = separatorIndex > 0
                ? rawValue.substring(separatorIndex + 1).trim()
                : '';

            return Semantics(
              button: onTap != null,
              label: '$title $rawValue',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 56),
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      14,
                      12,
                      14,
                      12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: SharedPlatformColors.border),
                    ),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              time,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.ltr,
                              style: const TextStyle(
                                color: Color(0xFF1F2937),
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: Color(0xFF9CA3AF),
                          ),
                          if (period.isNotEmpty) ...[
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                period,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textDirection: TextDirection.rtl,
                                style: const TextStyle(
                                  color: Color(0xFF1F2937),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
