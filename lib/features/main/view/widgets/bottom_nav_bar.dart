import 'package:flutter/material.dart';

import '../../../../core/auth/auth_gate.dart';
import '../../../../core/themes/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key, required this.controller});

  final TabController controller;

  Future<void> _onTabTap(BuildContext context, int index) async {
    if (index == 1) {
      await AuthGate.requireAuth(
        context,
        onAuthenticated: () => controller.animateTo(index),
        message: 'سجّل الدخول لعرض طلباتك',
      );
      return;
    }
    controller.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    const items = <_BottomNavItem>[
      _BottomNavItem(
        label: 'الرئيسية',
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
      ),
      _BottomNavItem(
        label: 'طلباتي',
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long_rounded,
      ),
      _BottomNavItem(
        label: 'حسابي',
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
      ),
    ];

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE7EAF0))),
              boxShadow: [
                BoxShadow(
                  color: Color(0x0D101828),
                  blurRadius: 18,
                  offset: Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: List.generate(items.length, (index) {
                final item = items[index];
                final selected = controller.index == index;
                return Expanded(
                  child: Semantics(
                    selected: selected,
                    button: true,
                    label: item.label,
                    child: InkWell(
                      onTap: () => _onTabTap(context, index),
                      borderRadius: BorderRadius.circular(14),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        constraints: const BoxConstraints(minHeight: 54),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFFE9F9FA)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              selected ? item.activeIcon : item.icon,
                              size: 23,
                              color: selected
                                  ? AppColors.primary
                                  : const Color(0xFF98A2B3),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.label,
                              style: TextStyle(
                                color: selected
                                    ? AppColors.primary
                                    : const Color(0xFF667085),
                                fontSize: 12,
                                fontWeight: selected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}

class _BottomNavItem {
  const _BottomNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}
