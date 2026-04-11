import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class OrdersCartOrdersSegmentBar extends StatelessWidget {
  const OrdersCartOrdersSegmentBar({super.key, required this.selectedIndex, required this.onChanged});

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const int cartIndex = 0;
  static const int ordersIndex = 1;

  static const _labels = <String>['قائمة المشتريات', 'الطلبيات'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [BoxShadow(color: Color(0x14000000), offset: Offset(0, 4), blurRadius: 12, spreadRadius: 0)],
      ),
      child: Row(
        children: [
          Expanded(
            child: _Segment(
              label: _labels[0],
              isSelected: selectedIndex == cartIndex,
              onTap: () {
                if (selectedIndex != cartIndex) onChanged(cartIndex);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _Segment(
              label: _labels[1],
              isSelected: selectedIndex == ordersIndex,
              onTap: () {
                if (selectedIndex != ordersIndex) onChanged(ordersIndex);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.label, required this.isSelected, required this.onTap});

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  static const _gradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[Color(0xFF1E2A78), Color(0xFF4A5FCF)],
  );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: isSelected ? _gradient : null,
            color: isSelected ? null : Colors.white,
            border: Border.all(color: isSelected ? Colors.transparent : const Color(0xFFE5E7EB)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Center(
              child: AppText.labelLarge(
                label,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
