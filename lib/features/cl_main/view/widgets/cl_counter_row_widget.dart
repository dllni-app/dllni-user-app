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
        CircleAvatar(
          backgroundColor: Color(0xff0CBBC7).withAlpha(31),
          child: Icon(icon, size: 18, color: const Color(0xff0CBBC7)),
        ),
        SizedBox(width: 18,),
        Expanded(
          child: AppText.bodyMedium(
            label,
            textAlign: TextAlign.start,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        _ActionCircleButton(icon: Icons.remove, onPressed: onDecrement, color: Color(0xffB2B9C1).withAlpha(80), iconColor: Colors.black,),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: AppText.bodyMedium(
            '$value',
            fontWeight: FontWeight.w700,
          ),
        ),
        _ActionCircleButton(icon: Icons.add, onPressed: onIncrement, color: Color(0xff0CBBC7), iconColor: Colors.white,),
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
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 14, color: iconColor),
      ),
    );
  }
}
