import 'package:dllni_user_app/core/themes/shared_platform_colors.dart';
import 'package:flutter/material.dart';

class VoteWinnerDialog extends StatelessWidget {
  const VoteWinnerDialog({
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
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF4E5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: Color(0xFF172554),
                size: 38,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'الاختيار الفائز',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF172033),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'انتهى التصويت واختارت المجموعة:',
              style: TextStyle(color: Color(0xFF667085), fontSize: 12),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F5FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: SharedPlatformColors.restaurant),
              ),
              child: Text(
                winnerName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF172033),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onShowBestOfferTap,
              style: FilledButton.styleFrom(
                backgroundColor: SharedPlatformColors.restaurant,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: const Text(
                'عرض المطاعم المناسبة',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'إغلاق',
                style: TextStyle(
                  color: Color(0xFF667085),
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
