import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class RsVoteWinnerDialog extends StatelessWidget {
  const RsVoteWinnerDialog({
    super.key,
    required this.winnerName,
    required this.onShowBestOfferTap,
  });

  final String winnerName;
  final VoidCallback onShowBestOfferTap;

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
                color: const Color(0xffFF7A00).withAlpha(20),
                border: Border.all(color: const Color(0xffFF7A00), width: 2),
              ),
              child: const Icon(
                Icons.emoji_events_outlined,
                color: Color(0xffFF7A00),
                size: 46,
              ),
            ),
            const SizedBox(height: 16),
            AppText.titleMedium(
              'الخيار الفائز:',
              color: const Color(0xff374151),
              fontWeight: FontWeight.w700,
            ),
            const SizedBox(height: 4),
            AppText.headlineMedium(
              winnerName,
              color: const Color(0xffD97706),
              fontWeight: FontWeight.w800,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onShowBestOfferTap,
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
                  'عرض أفضل مطعم يقدمه',
                  color: context.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
