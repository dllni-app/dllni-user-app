import 'package:flutter/material.dart';

import '../../../../core/themes/shared_platform_colors.dart';

class OrdersAppBar extends StatelessWidget {
  const OrdersAppBar({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const _items = <_OrderSectionItem>[
    _OrderSectionItem(
      label: 'سوبرماركت',
      icon: Icons.shopping_basket_outlined,
      accent: SharedPlatformColors.supermarket,
      soft: SharedPlatformColors.supermarketSoft,
    ),
    _OrderSectionItem(
      label: 'مطاعم',
      icon: Icons.restaurant_outlined,
      accent: SharedPlatformColors.restaurant,
      soft: SharedPlatformColors.restaurantSoft,
    ),
    _OrderSectionItem(
      label: 'تنظيف',
      icon: Icons.cleaning_services_outlined,
      accent: SharedPlatformColors.cleaning,
      soft: SharedPlatformColors.cleaningSoft,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE7EAF0))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'طلباتي',
            textAlign: TextAlign.start,
            style: TextStyle(
              color: SharedPlatformColors.ink,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'تابع طلباتك وسلاتك في كل أقسام دلني.',
            textAlign: TextAlign.start,
            style: TextStyle(color: SharedPlatformColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final selected = selectedIndex == index;
              return Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                    end: index == _items.length - 1 ? 0 : 7,
                  ),
                  child: Material(
                    color: selected ? item.soft : const Color(0xFFF7F8FA),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () {
                        if (!selected) onChanged(index);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        height: 46,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? item.accent.withAlpha(90)
                                : SharedPlatformColors.border,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              item.icon,
                              size: 17,
                              color: selected
                                  ? item.accent
                                  : SharedPlatformColors.subtle,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                item.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: selected
                                      ? item.accent
                                      : SharedPlatformColors.muted,
                                  fontSize: 11,
                                  fontWeight: selected
                                      ? FontWeight.w900
                                      : FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _OrderSectionItem {
  const _OrderSectionItem({
    required this.label,
    required this.icon,
    required this.accent,
    required this.soft,
  });

  final String label;
  final IconData icon;
  final Color accent;
  final Color soft;
}
