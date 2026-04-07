import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class RsOffersAppBar extends StatelessWidget {
  const RsOffersAppBar({super.key, this.title = 'العروض'});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      padding: EdgeInsets.fromLTRB(16, 16 + MediaQuery.paddingOf(context).top, 16, 20),
      decoration: BoxDecoration(
        color: context.onPrimary,
        border: Border(bottom: BorderSide(color: context.primaryContainer, width: 2)),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: const [BoxShadow(offset: Offset(0, 1), blurRadius: 2, color: Color(0x0D000000))],
      ),
      child: AppText(
        title,
        textAlign: TextAlign.start,
        style: TextStyle(color: context.primary, fontSize: 24, fontWeight: FontWeight.w700, height: 32 / 24),
      ),
    );
  }
}
