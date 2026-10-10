import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF172554),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF172033),
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
