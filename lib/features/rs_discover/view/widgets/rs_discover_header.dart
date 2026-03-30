import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class RsDiscoverHeader extends StatelessWidget {
  const RsDiscoverHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.onPrimary,
        border: Border(
          bottom: BorderSide(color: context.primaryContainer, width: 2),
        ),
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(27),
            offset: const Offset(0, -2),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      width: context.width,
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 18),
      child: AppText.headlineLarge(
        'اكتشف',
        fontWeight: FontWeight.w700,
        textAlign: TextAlign.start,
      ),
    );
  }
}
