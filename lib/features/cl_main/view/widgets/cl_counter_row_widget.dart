import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class ClCounterRowWidget extends StatelessWidget {
  const ClCounterRowWidget({
    required this.label,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
    required this.icon,
    super.key,
  });

  final String label;
  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Color(0xff0CBBC7).withAlpha(31),
            shape: BoxShape.circle,
          ),
      
          child: Icon(icon, size: 18, color: const Color(0xff0CBBC7)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: AppText.titleSmall(
            label,
            textAlign: TextAlign.start,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 6),
        _ActionCircleButton(
          icon: Icons.remove,
          onPressed: onDecrement,
          color: Color(0xffB2B9C1).withAlpha(80),
          iconColor: Colors.black,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: AppText.titleSmall(
            '$value',
            fontWeight: FontWeight.w600,
          ),
        ),
        _ActionCircleButton(
          icon: Icons.add,
          
          onPressed: onIncrement,
          color: Color(0xff0CBBC7),
          iconColor: Colors.white,
        ),
      ],
    );
  }
}

class _ActionCircleButton extends StatelessWidget {
  const _ActionCircleButton({required this.icon, required this.onPressed, required this.color, required this.iconColor});

  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
    );
  }
}
