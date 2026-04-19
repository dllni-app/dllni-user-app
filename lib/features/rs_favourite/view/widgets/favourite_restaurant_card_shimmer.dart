import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class FavouriteRestaurantCardShimmer extends StatelessWidget {
  const FavouriteRestaurantCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: context.onPrimary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 14,
            width: double.infinity,
            color: const Color(0xFFF3F4F6),
          ),
          const SizedBox(height: 10),
          FractionallySizedBox(
            widthFactor: 0.65,
            child: Container(height: 12, color: const Color(0xFFF3F4F6)),
          ),
        ],
      ),
    );
  }
}
