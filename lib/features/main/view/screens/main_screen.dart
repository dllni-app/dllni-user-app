import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/widgets/exit_confirmation_dialog.dart';
import '../../../../core/themes/shared_platform_colors.dart';

import '../../../home/view/screens/home_screen.dart';
import '../../../orders/view/screens/orders_screen.dart';
import '../../../profile/view/screens/profile_screen.dart';
import '../widgets/bottom_nav_bar.dart';

@AutoRoutePage()
class MainScreen extends StatefulWidget {
  const MainScreen({super.key, this.returnedIndex});

  final int? returnedIndex;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late final TabController controller;
  bool _isExitDialogVisible = false;

  @override
  void initState() {
    super.initState();
    final initialIndex = (widget.returnedIndex ?? 0).clamp(0, 2);
    controller = TabController(
      length: 3,
      vsync: this,
      initialIndex: initialIndex,
    );
  }

  Future<void> _handleBackPressed() async {
    if (controller.index != 0) {
      controller.animateTo(0);
      return;
    }

    if (_isExitDialogVisible) return;
    _isExitDialogVisible = true;
    try {
      final shouldExit = await showExitConfirmationDialog(context);
      if (shouldExit && mounted) {
        await SystemNavigator.pop();
      }
    } finally {
      _isExitDialogVisible = false;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBackPressed();
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: SharedPlatformColors.background,
        body: SafeArea(
          child: TabBarView(
            controller: controller,
            physics: const NeverScrollableScrollPhysics(),
            children: const [HomeScreen(), OrdersScreen(), ProfileScreen()],
          ),
        ),
        bottomNavigationBar: BottomNavBar(controller: controller),
      ),
      ),
    );
  }
}
