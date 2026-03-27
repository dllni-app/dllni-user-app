import 'package:flutter/material.dart';

import '../themes/app_colors.dart';

class AppSwitch extends StatefulWidget {
  const AppSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor = AppColors.accent,
    this.inactiveColor = const Color(0x292F2B3D),
  });
  final bool value;
  final void Function(bool value)? onChanged;
  final Color activeColor;
  final Color inactiveColor;

  @override
  State<AppSwitch> createState() => _AppSwitchState();
}

class _AppSwitchState extends State<AppSwitch> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: widget.onChanged == null
            ? null
            : () {
                widget.onChanged!(!widget.value);
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 44,
          height: 24,
          padding: EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: widget.onChanged == null
                ? Color(0x292F2B3D)
                : widget.value
                ? widget.activeColor
                : widget.inactiveColor,
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            alignment: widget.value
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
