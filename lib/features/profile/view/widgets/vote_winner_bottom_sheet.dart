import 'package:dllni_user_app/core/themes/shared_platform_colors.dart';
import 'package:flutter/material.dart';

class VoteWinnerBottomSheet extends StatelessWidget {
  const VoteWinnerBottomSheet({
    super.key,
    required this.winnerName,
    required this.onShowBestOfferTap,
  });

  final String winnerName;
  final VoidCallback onShowBestOfferTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: _VoteWinnerContent(
        winnerName: winnerName,
        onShowBestOfferTap: onShowBestOfferTap,
      ),
    );
  }
}

class _VoteWinnerContent extends StatelessWidget {
  const _VoteWinnerContent({
    required this.winnerName,
    required this.onShowBestOfferTap,
  });

  final String winnerName;
  final VoidCallback onShowBestOfferTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 18, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD0D5DD),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 22),
          Container(
            width: 76,
            height: 76,
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
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF667085), fontSize: 12),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F5FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SharedPlatformColors.restaurant),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: SharedPlatformColors.restaurant,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  winnerName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF172033),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF0FA),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الخطوة التالية',
                  style: TextStyle(
                    color: SharedPlatformColors.restaurant,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'اعرض المطاعم التي تقدم الاختيار الفائز وأكمل طلبك.',
                  style: TextStyle(
                    color: Color(0xFF66708C),
                    fontSize: 11,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: onShowBestOfferTap,
            style: FilledButton.styleFrom(
              backgroundColor: SharedPlatformColors.restaurant,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'عرض المطاعم المناسبة',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
