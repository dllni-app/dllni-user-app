import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/themes/app_colors.dart';
import '../screens/sm_store_details_screen.dart';

class StoreStatusSection extends StatelessWidget {
  const StoreStatusSection({super.key, this.store});
  final SmStarterStoreDetailsData? store;

  @override
  Widget build(BuildContext context) {
    final s = store;
    final unknownHeader = s == null;
    final statusUnknown = store?.isActive == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          unknownHeader
                              ? '…'
                              : (s.name?.isNotEmpty == true ? s.name! : ''),
                          style: TextStyle(
                            color: unknownHeader
                                ? Color(0xFF9CA3AF)
                                : Color(0xFF111827),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            height: 28 / 20,
                          ),
                        ),
                        SizedBox(height: 4),
                        AppText(
                          unknownHeader ? '' : (s.description ?? '').trim(),
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 16 / 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (unknownHeader)
                    _NeutralRatingPlaceholder()
                  else
                    _RateChip(
                      rate: double.tryParse(s.averageRating ?? '') ?? 0,
                      totalReviews: s.totalReviews ?? 0,
                    ),
                ],
              ),
              SizedBox(height: 24),
              if (statusUnknown)
                _NeutralStatusPlaceholder(width: context.width)
              else
                Builder(
                  builder: (context) {
                    final st = store!;
                    return Container(
                      width: context.width,
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 4,
                            backgroundColor: Color(0xFF22C55E),
                          ),
                          SizedBox(width: 8),
                          AppText(
                            st.isActive == true ? "مفتوح الآن" : "مغلق الآن",
                            style: TextStyle(
                              color: Color(0xFF15803D),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              height: 20 / 14,
                            ),
                            color: st.isActive == true
                                ? Color(0xFF15803D)
                                : Color(0xFFEF4444),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              SizedBox(height: 10),

              // Container(
              //   width: context.width,
              //   alignment: Alignment.center,
              //   padding: EdgeInsets.symmetric(vertical: 8),
              //   decoration: BoxDecoration(
              //     color: Color(0xFFF9FAFB),
              //     borderRadius: BorderRadius.all(Radius.circular(12)),
              //   ),
              //   child: Row(
              //     mainAxisSize: MainAxisSize.min,
              //     children: [
              //       FaIcon(
              //         FontAwesomeIcons.solidClock,
              //         size: 14,
              //         color: Color(0xFF6B7280),
              //       ),
              //       SizedBox(width: 8),
              //       AppText(
              //         "30 - 40 دقيقة",
              //         style: TextStyle(
              //           color: Color(0xFF374151),
              //           fontSize: 14,
              //           fontWeight: FontWeight.w500,
              //           height: 20 / 14,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NeutralRatingPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFFF3F4F6),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: AppText(
        '—',
        style: TextStyle(
          color: Color(0xFF9CA3AF),
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 28 / 18,
        ),
      ),
    );
  }
}

class _NeutralStatusPlaceholder extends StatelessWidget {
  const _NeutralStatusPlaceholder({required this.width});
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFFF3F4F6),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: AppText(
        '…',
        style: TextStyle(
          color: Color(0xFF9CA3AF),
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 20 / 14,
        ),
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
      decoration: BoxDecoration(
        color: Color(0x1A4CAF50),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            FontAwesomeIcons.solidStar,
            size: 14,
            color: Color(0xFFEAB308),
          ),
          SizedBox(width: 4),
          AppText(
            rate.toStringAsFixed(1),
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 28 / 18,
            ),
          ),
          SizedBox(width: 4),
          AppText(
            "($totalReviews)",
            style: TextStyle(
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
