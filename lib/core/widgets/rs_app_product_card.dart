import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class RsAppProductCard extends StatelessWidget {
  const RsAppProductCard({
    super.key,
    required this.image,
    required this.title,
    required this.restaurant,
    required this.price,
    required this.offer,
    required this.onTap,
  });

  final String image;
  final String title;
  final String restaurant;
  final String price;
  final String offer;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Color(0xffF3F4F6), width: 1),
          color: context.onPrimary,
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 12),
              child: Column(
                children: [
                  AppImage.network(image, width: context.width, height: 100, fit: BoxFit.cover, borderRadius: BorderRadius.circular(16)),
                  SizedBox(height: 12),
                  AppText.bodyMedium(title, fontWeight: FontWeight.bold, maxLines: 1, scrollText: true),
                  SizedBox(height: 4),
                  AppText.bodyMedium(restaurant, fontWeight: FontWeight.w400, maxLines: 1, scrollText: true, color: Color(0xff6B7280)),
                  SizedBox(height: 6),
                  AppText.bodyMedium(price, fontWeight: FontWeight.bold, maxLines: 1, color: Color(0xff1E2A78)),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: context.primaryContainer,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                  ),
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 4),
                  child: AppText.labelSmall(offer, fontWeight: FontWeight.bold, color: context.onPrimaryContainer),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
