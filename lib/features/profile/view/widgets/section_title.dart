import 'package:common_package/widgets/app_text.dart';
import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 20,
          child: VerticalDivider(
            color: Colors.black,
            thickness: 4,
            radius: BorderRadius.circular(9999),
          ),
        ),
        SizedBox(width: 8),
        AppText.titleMedium(title, fontWeight: FontWeight.bold),
      ],
    );
  }
}
