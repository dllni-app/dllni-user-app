import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class RsProfileAppBar extends StatelessWidget {
  const RsProfileAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.onPrimary,
        border: Border(bottom: BorderSide(color: context.primaryContainer, width: 2)),
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(24), bottomLeft: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(27), offset: Offset(0, -2), blurRadius: 12, spreadRadius: 0)],
      ),
      width: context.width,
      padding: EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 16),
      child: AppText.headlineLarge('حسابي', fontWeight: FontWeight.w700, textAlign: TextAlign.start),
    );
  }
}
