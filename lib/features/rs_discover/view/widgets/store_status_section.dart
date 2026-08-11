import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StoreStatusSection extends StatelessWidget {
  const StoreStatusSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.totalReviews,
    required this.isOpenNow,
    required this.preparationTimeLabel,
  });

  final String title;
  final String subtitle;
  final double rating;
  final int totalReviews;
  final bool? isOpenNow;
  final String preparationTimeLabel;

  @override
  Widget build(BuildContext context) {
    final status = isOpenNow;
    final statusText = status == null
        ? 'حالة الدوام غير متاحة'
        : status
        ? 'مفتوح الآن'
        : 'مغلق الآن';
    final statusBackgroundColor = status == null
        ? const Color(0xFFF3F4F6)
        : status
        ? const Color(0xFFF0FDF4)
        : const Color(0xFFFEF2F2);
    final statusColor = status == null
        ? const Color(0xFF6B7280)
        : status
        ? const Color(0xFF15803D)
        : const Color(0xFFDC2626);
    final statusDotColor = status == null
        ? const Color(0xFF9CA3AF)
        : status
        ? const Color(0xFF22C55E)
        : const Color(0xFFEF4444);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppText(
                  title,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 28 / 20,
                  ),
                ),
              ),
              _RateChip(rate: rating, totalReviews: totalReviews),
            ],
          ),
          const SizedBox(height: 4),
          if (subtitle.isNotEmpty)
            AppText(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 16 / 12,
              ),
            ),
          const SizedBox(height: 36),
          Container(
            width: context.width,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: statusBackgroundColor,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 4, backgroundColor: statusDotColor),
                const SizedBox(width: 8),
                AppText(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 20 / 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: _StatusChip(
              label: preparationTimeLabel,
              icon: FontAwesomeIcons.solidClock,
            ),
          ),
        ],
      ),
    );
  }
}

class _RateChip extends StatelessWidget {
  const _RateChip({required this.rate, required this.totalReviews});

  final num rate;
  final int totalReviews;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xff4CAF50).withAlpha(25),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FaIcon(
            FontAwesomeIcons.solidStar,
            size: 14,
            color: Color(0xFFEAB308),
          ),
          const SizedBox(width: 8),
          AppText(
            rate.toStringAsFixed(1),
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 28 / 15,
            ),
          ),
          const SizedBox(width: 4),
          AppText(
            '($totalReviews)',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 20 / 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.icon});

  final String label;
  final FaIconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Color(0xffF9FAFB),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(icon, size: 14, color: const Color(0xFF6B7280)),
          const SizedBox(width: 8),
          AppText(
            label,
            style: const TextStyle(
              color: Color(0xFF374151),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 20 / 12,
            ),
          ),
        ],
      ),
    );
  }
}
