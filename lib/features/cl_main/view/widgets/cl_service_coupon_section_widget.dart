import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/generated/assets.dart';
import 'package:flutter/material.dart';

enum ClCouponUiStatus { idle, loading, success, failed }

class ClServiceCouponSectionWidget extends StatelessWidget {
  const ClServiceCouponSectionWidget({
    required this.couponController,
    required this.status,
    required this.onApply,
    this.message,
    this.title = 'هل لديك كود حسم ؟',
    this.hintText = 'ادخل كود الحسم هنا',
    this.applyButtonText = 'تطبيق',
    super.key,
  });

  final TextEditingController couponController;
  final ClCouponUiStatus status;
  final ValueChanged<String> onApply;
  final String? message;
  final String title;
  final String hintText;
  final String applyButtonText;

  @override
  Widget build(BuildContext context) {
    final hasFeedback =
        status == ClCouponUiStatus.success || status == ClCouponUiStatus.failed;
    final isSuccess = status == ClCouponUiStatus.success;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppImage.asset(
                Assets.images.rsProfileCoupon.path,
                color: const Color(0xFF11B9C8),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: AppText.bodyMedium(
                  title,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                  textAlign: TextAlign.start,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: status == ClCouponUiStatus.loading
                      ? null
                      : () => onApply(couponController.text.trim()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E2A78),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 20,
                    ),
                  ),
                  child: status == ClCouponUiStatus.loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : AppText.labelLarge(
                          applyButtonText,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: couponController,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    contentPadding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF1E2A78)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (hasFeedback) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSuccess
                    ? const Color(0xFFECFDF3)
                    : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    isSuccess ? Icons.check_circle : Icons.error_outline,
                    size: 18,
                    color: isSuccess
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppText.bodySmall(
                      message ??
                          (isSuccess
                              ? 'تم تطبيق الكوبون بنجاح.'
                              : 'تعذر تطبيق الكوبون حالياً.'),
                      color: isSuccess
                          ? const Color(0xFF10B981)
                          : const Color(0xFFB91C1C),
                      fontWeight: FontWeight.w600,
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
