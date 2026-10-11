import 'package:flutter/material.dart';

import '../../../../core/themes/shared_platform_colors.dart';

/// Pen V7 account header — quiet surface, no legacy navy billboard.
class ProfileAppBar extends StatelessWidget {
  const ProfileAppBar({super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    constraints: const BoxConstraints(minHeight: 68),
    padding: const EdgeInsetsDirectional.fromSTEB(18, 11, 18, 12),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: Color(0xFFE6EAF0))),
    ),
    child: const Row(
      children: [
        Icon(
          Icons.account_circle_outlined,
          color: SharedPlatformColors.primary,
          size: 23,
        ),
        SizedBox(width: 10),
        Text(
          'حسابي',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: SharedPlatformColors.primary,
          ),
        ),
      ],
    ),
  );
}
