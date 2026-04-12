import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class PersonalDetailsAppBar extends StatelessWidget {
  const PersonalDetailsAppBar({
    super.key,
    required this.title,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String title;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final resolvedBackgroundColor = backgroundColor ?? context.onPrimary;
    final resolvedForegroundColor = foregroundColor ?? context.primary;
    return Container(
      decoration: BoxDecoration(
        color: resolvedBackgroundColor,
        border: Border(
          bottom: BorderSide(color: context.primaryContainer, width: 3),
        ),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(27),
            offset: Offset(0, -2),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      width: context.width,
      height: 70,
      padding: EdgeInsetsDirectional.symmetric(horizontal: 16),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => context.pop(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: context.onPrimary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xffE5E7EB)),
              ),
              child: Icon(Icons.arrow_back, color: resolvedForegroundColor),
            ),
          ),
          SizedBox(width: 9),
          Expanded(
            child: AppText.headlineMedium(
              title,
              color: resolvedForegroundColor,
              fontWeight: FontWeight.bold,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
}
