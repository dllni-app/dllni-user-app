import 'package:flutter/material.dart';
import '../../../../core/themes/shared_platform_colors.dart';

/// Compact, accessible V7 cart/orders selector.
class OrdersCartOrdersSegmentBar extends StatelessWidget {
  const OrdersCartOrdersSegmentBar({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
    this.accent = SharedPlatformColors.primary,
  });
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final Color accent;
  static const int cartIndex = 0;
  static const int ordersIndex = 1;
  static const _labels = <String>['السلات', 'الطلبات'];

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: const Color(0xFFF0F2F5),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        for (var index = 0; index < 2; index++) ...[
          if (index > 0) const SizedBox(width: 4),
          Expanded(
            child: Semantics(
              button: true,
              selected: selectedIndex == index,
              child: Material(
                color: selectedIndex == index
                    ? Colors.white
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () => selectedIndex != index ? onChanged(index) : null,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 43),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: selectedIndex == index
                          ? Border.all(color: accent.withValues(alpha: 0.35))
                          : null,
                    ),
                    child: Text(
                      _labels[index],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: selectedIndex == index
                            ? SharedPlatformColors.primary
                            : SharedPlatformColors.muted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}
