import 'package:flutter/material.dart';

/// Explicit empty state so GPS failures never look like an empty screen.
class NearbyStoresEmptyState extends StatelessWidget {
  const NearbyStoresEmptyState({super.key, this.onBrowse});

  final VoidCallback? onBrowse;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 12),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.storefront_outlined,
              size: 38,
              color: Color(0xFF64748B),
            ),
            const SizedBox(height: 12),
            const Text(
              'لا توجد متاجر قريبة منك حالياً',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            const Text(
              'يمكنك تصفّح جميع المتاجر والمنتجات بدلاً من البحث حسب موقعك.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            if (onBrowse != null)
              TextButton.icon(
                onPressed: onBrowse,
                icon: const Icon(Icons.search),
                label: const Text('تصفح جميع المتاجر'),
              ),
          ],
        ),
      ),
    );
  }
}
