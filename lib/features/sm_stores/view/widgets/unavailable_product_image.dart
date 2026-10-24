import 'package:flutter/material.dart';

/// A readable fallback for products whose photos are absent or unusable.
class UnavailableProductImage extends StatelessWidget {
  const UnavailableProductImage({
    super.key,
    this.height,
    this.width,
    this.iconSize = 34,
  });

  final double? height;
  final double? width;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF1F5F4),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              color: const Color(0xFF64748B),
              size: iconSize,
            ),
            const SizedBox(height: 6),
            const Text(
              'صورة المنتج غير متوفرة',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
