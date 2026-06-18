import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class ClServiceAddressSectionWidget extends StatelessWidget {
  const ClServiceAddressSectionWidget({
    super.key,
    this.locationName = 'المنزل',
    this.address = 'العنوان غير محدد',
    this.showChangeAction = true,
    this.onChangeTap,
  });

  final String locationName;
  final String address;
  final bool showChangeAction;
  final VoidCallback? onChangeTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                color: Color(0xFF1E2A78),
                size: 18,
              ),
              const SizedBox(width: 6),
              AppText.bodyLarge(
                'عنوان الخدمة',
                color: const Color(0xFF1E2A78),
                fontWeight: FontWeight.w700,
                textAlign: TextAlign.right,
              ),
              const Spacer(),
              if (showChangeAction)
                InkWell(
                  onTap: onChangeTap,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9E9F3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: AppText.labelLarge(
                      'عرض',
                      color: const Color(0xFF1E2A78),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bodyMedium(
                  locationName,
                  color: const Color(0xFF1F2937),
                  fontWeight: FontWeight.w700,
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 4),
                AppText.labelLarge(
                  address,
                  color: const Color(0xFF6B7280),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
