import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class OrderVotingSuccessDialog extends StatelessWidget {
  const OrderVotingSuccessDialog({
    super.key,
    required this.onContinueTap,
    required this.onShareTap,
  });

  final VoidCallback onContinueTap;
  final VoidCallback onShareTap;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 28, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xffFF7A00).withAlpha(25),
                border: Border.all(color: const Color(0xffFF7A00), width: 2),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Color(0xffFF7A00),
                size: 46,
              ),
            ),
            const SizedBox(height: 20),
            AppText.headlineMedium(
              'تم إنشاء التصويت',
              color: const Color(0xff374151),
              fontWeight: FontWeight.w700,
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onContinueTap,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                      side: const BorderSide(color: Color(0xffFF7A00)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                    child: AppText.labelLarge(
                      'متابعة التصويت',
                      color: const Color(0xffFF7A00),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onShareTap,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      minimumSize: const Size.fromHeight(46),
                      backgroundColor: context.primary,
                      foregroundColor: context.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                    child: AppText.labelLarge(
                      'مشاركة',
                      color: context.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
