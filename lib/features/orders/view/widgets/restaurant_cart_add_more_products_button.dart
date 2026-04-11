import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class RestaurantCartAddMoreProductsButton extends StatelessWidget {
  const RestaurantCartAddMoreProductsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.pushRoute('/home'),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xffD1D5DB), width: 1.3),
        ),
        child: Center(
          child: AppText.labelLarge(
            'إضافة منتجات أخرى',
            color: const Color(0xff4B5563),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
