import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class RestaurantCartEmptyView extends StatelessWidget {
  const RestaurantCartEmptyView({super.key, required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * .12),
          Icon(Icons.shopping_cart_outlined, size: 72, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          AppText.titleMedium(
            'قائمة المشتريات',
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E2A78),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          AppText.bodyMedium(
            'تصفح المطاعم وأضف المنتجات إلى سلتك من هنا.',
            color: const Color(0xFF6B7280),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Center(
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1E2A78),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => context.pushRoute('/rsmain'),
              child: AppText.labelLarge(
                'تصفح المطاعم',
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
