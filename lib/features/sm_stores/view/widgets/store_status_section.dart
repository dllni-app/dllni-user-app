import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/themes/app_colors.dart';
import '../../data/models/get_supermarket_store_details_model.dart';
import '../screens/sm_store_details_screen.dart';

bool? supermarketStoreIsOpenNow(
  List<SupermarketStoreDetailsHour>? hours, {
  DateTime? now,
}) {
  if (hours == null || hours.isEmpty) return null;

  final current = now ?? DateTime.now();
  final currentMinutes = (current.hour * 60) + current.minute;
  final currentDay = current.weekday % 7; // Sunday = 0 … Saturday = 6.
  final previousDay = (currentDay + 6) % 7;

  for (final hour in hours) {
    if (hour.isClosed == true ||
        supermarketStoreDetailsHourDayIndex(hour.dayOfWeek) != currentDay) {
      continue;
    }

    final openMinutes = _timeToMinutes(hour.openTime);
    final closeMinutes = _timeToMinutes(hour.closeTime);
    if (openMinutes == null || closeMinutes == null) continue;

    // Same opening and closing time is treated as a 24-hour opening.
    if (openMinutes == closeMinutes) return true;

    if (closeMinutes > openMinutes &&
        currentMinutes >= openMinutes &&
        currentMinutes < closeMinutes) {
      return true;
    }

    // Opening interval crosses midnight, e.g. 18:00 -> 02:00.
    if (closeMinutes < openMinutes && currentMinutes >= openMinutes) {
      return true;
    }
  }

  // Handle the after-midnight part of an overnight interval from yesterday.
  for (final hour in hours) {
    if (hour.isClosed == true ||
        supermarketStoreDetailsHourDayIndex(hour.dayOfWeek) != previousDay) {
      continue;
    }

    final openMinutes = _timeToMinutes(hour.openTime);
    final closeMinutes = _timeToMinutes(hour.closeTime);
    if (openMinutes == null || closeMinutes == null) continue;

    if (closeMinutes < openMinutes && currentMinutes < closeMinutes) {
      return true;
    }
  }

  return false;
}

int? _timeToMinutes(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final parts = value.trim().split(':');
  if (parts.length < 2) return null;

  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

  return (hour * 60) + minute;
}

class StoreStatusSection extends StatelessWidget {
  const StoreStatusSection({super.key, this.store});
  final SmStarterStoreDetailsData? store;

  @override
  Widget build(BuildContext context) {
    final s = store;
    final unknownHeader = s == null;
    final isOpenNow = supermarketStoreIsOpenNow(s?.storeHours);
    final statusUnknown = isOpenNow == null;
    final isOpen = isOpenNow == true;
    final statusBackgroundColor = statusUnknown
        ? const Color(0xFFF3F4F6)
        : isOpen
        ? const Color(0xFFF0FDF4)
        : const Color(0xFFFEF2F2);
    final statusColor = statusUnknown
        ? const Color(0xFF6B7280)
        : isOpen
        ? const Color(0xFF15803D)
        : const Color(0xFFDC2626);
    final statusDotColor = statusUnknown
        ? const Color(0xFF9CA3AF)
        : isOpen
        ? const Color(0xFF22C55E)
        : const Color(0xFFEF4444);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: const BoxDecoration(
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
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFF111827),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            height: 28 / 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AppText(
                          unknownHeader ? '' : (s.description ?? '').trim(),
                          style: const TextStyle(
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
              const SizedBox(height: 24),
              if (statusUnknown)
                _NeutralStatusPlaceholder(width: context.width)
              else
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
                        isOpen ? 'مفتوح الآن' : 'مغلق الآن',
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFF3F4F6),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: const AppText(
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFF3F4F6),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: const AppText(
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0x1A4CAF50),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FaIcon(
            FontAwesomeIcons.solidStar,
            size: 14,
            color: Color(0xFFEAB308),
          ),
          const SizedBox(width: 4),
          AppText(
            rate.toStringAsFixed(1),
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 28 / 18,
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
