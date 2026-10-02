import 'package:dllni_user_app/core/themes/shared_platform_colors.dart';
import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class RestaurantCartCheckoutFulfillmentButton extends StatelessWidget {
  const RestaurantCartCheckoutFulfillmentButton({
    super.key,
    required this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: SharedPlatformColors.restaurant,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: AppText.bodyLarge(
          'تحديد طريقة استلام الطلب',
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
