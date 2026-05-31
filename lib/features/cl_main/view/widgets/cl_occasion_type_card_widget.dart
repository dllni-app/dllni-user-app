import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class ClOccasionTypeCardWidget extends StatelessWidget {
  const ClOccasionTypeCardWidget({required this.title, required this.imagePath, required this.onTap, super.key});

  final String title;
  final String imagePath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 182,
        width: context.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
        ),
        padding: EdgeInsetsDirectional.symmetric(vertical: 12, horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: AppText.bodyMedium(title, fontWeight: FontWeight.w700, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
