import 'package:flutter/material.dart';

class RestaurantOrderCircleIconButton extends StatelessWidget {
  const RestaurantOrderCircleIconButton({
    super.key,
    required this.background,
    required this.icon,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  final Color background;
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(icon, color: iconColor, size: 22),
        ),
      ),
    );
  }
}
