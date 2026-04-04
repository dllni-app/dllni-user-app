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
  final bool isOpenNow;
  final String preparationTimeLabel;

  @override
  Widget build(BuildContext context) {
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
                  style: TextStyle(color: Color(0xFF111827), fontSize: 20, fontWeight: FontWeight.w700, height: 28 / 20),
                ),
              ),
              _RateChip(rate: rating, totalReviews: totalReviews),
            ],
          ),
          SizedBox(height: 4),
          if (subtitle.isNotEmpty)
            AppText(
              subtitle,
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 12, fontWeight: FontWeight.w500, height: 16 / 12),
            ),
          SizedBox(height: 36),
          Container(
            width: context.width,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(color: Color(0xFFF0FDF4), borderRadius: BorderRadius.all(Radius.circular(12))),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 4, backgroundColor: Color(0xFF22C55E)),
                SizedBox(width: 8),
                AppText(
                  isOpenNow ? "مفتوح الآن" : "مغلق حالياً",
                  style: TextStyle(color: Color(0xFF15803D), fontSize: 14, fontWeight: FontWeight.w700, height: 20 / 14),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Row(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _StatusChip(label: preparationTimeLabel, icon: FontAwesomeIcons.solidClock)),
              Expanded(child: _StatusChip(label: "توصيل مجاني", icon: FontAwesomeIcons.motorcycle)),
            ],
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
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Color(0xff4CAF50).withAlpha(25), borderRadius: BorderRadius.all(Radius.circular(12))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(FontAwesomeIcons.solidStar, size: 14, color: Color(0xFFEAB308)),
          SizedBox(width: 8),
          AppText(
            rate.toStringAsFixed(1),
            style: TextStyle(color: Color(0xFF111827), fontSize: 15, fontWeight: FontWeight.w700, height: 28 / 15),
          ),
          SizedBox(width: 4),
          AppText(
            "($totalReviews)",
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 12, fontWeight: FontWeight.w500, height: 20 / 12),
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
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(color: Color(0xffF9FAFB), borderRadius: BorderRadius.all(Radius.circular(12))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(icon, size: 14, color: Color(0xFF6B7280)),
          SizedBox(width: 8),
          AppText(
            label,
            style: TextStyle(color: Color(0xFF374151), fontSize: 12, fontWeight: FontWeight.w500, height: 20 / 12),
          ),
        ],
      ),
    );
  }
}
