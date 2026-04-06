import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class PersonalDetailsAppBar extends StatelessWidget {
  const PersonalDetailsAppBar({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.onPrimary,
        border: Border(bottom: BorderSide(color: context.primaryContainer, width: 3)),
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(24), bottomLeft: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(27), offset: Offset(0, -2), blurRadius: 12, spreadRadius: 0)],
      ),
      width: context.width,
      height: 70,
      padding: EdgeInsetsDirectional.symmetric(horizontal: 16),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              context.pop();
            },
            child: Icon(Icons.arrow_back_ios_new, color: context.primary),
          ),
          SizedBox(width: 9),
          Expanded(
            child: AppText.headlineMedium(title, color: context.primary, fontWeight: FontWeight.bold, textAlign: TextAlign.start),
          ),
        ],
      ),
    );
  }
}
