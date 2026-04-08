import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class RestaurantOrderCard extends StatelessWidget {
  const RestaurantOrderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xffE5E7EB), width: 1),
        color: context.onPrimary,
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), offset: Offset(0, 1), blurRadius: 2)],
      ),
      padding: EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText.titleSmall('الطلبية الحالية', color: Colors.black, fontWeight: FontWeight.bold),
              Icon(Icons.delete_outline_outlined, color: Color(0xffEF4444)),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              AppText.labelLarge('المطاعم:', color: Color(0xff1F2937), fontWeight: FontWeight.w500),
              Expanded(
                child: AppText.labelLarge('برغر كينغ + بيتزا هت', color: Color(0xff6B7280), fontWeight: FontWeight.w500, textAlign: TextAlign.start),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              AppText.labelLarge('الطلبات:', color: Color(0xff1F2937), fontWeight: FontWeight.w500),
              Expanded(
                child: AppText.labelLarge(
                  'برغر كلاسيك كبير (×2) - بيتزا (×1)',
                  color: Color(0xff6B7280),
                  fontWeight: FontWeight.w500,
                  textAlign: TextAlign.start,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
