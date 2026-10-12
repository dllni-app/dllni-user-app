import 'package:flutter/material.dart';

import '../../../../core/auth/auth_gate.dart';
import '../../../../core/widgets/design_system/design_system.dart';

/// V6 shared navigation; the existing AuthGate remains responsible for orders.
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key, required this.controller});
  final TabController controller;

  Future<void> _select(BuildContext context, int index) async {
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
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => AppBottomNavigation(
        selectedIndex: controller.index,
        onSelect: (index) => _select(context, index),
        destinations: const [
          AppNavDestination(
            label: 'الرئيسية',
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
          ),
          AppNavDestination(
            label: 'طلباتي',
            icon: Icons.receipt_long_outlined,
            selectedIcon: Icons.receipt_long_rounded,
          ),
          AppNavDestination(
            label: 'حسابي',
            icon: Icons.person_outline_rounded,
            selectedIcon: Icons.person_rounded,
          ),
        ],
      ),
    );
  }
}
