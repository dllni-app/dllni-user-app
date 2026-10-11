import 'dart:ui' as ui;
import 'package:dllni_user_app/core/extensions/extentions.dart';
import 'package:flutter/material.dart';
import '../../../../core/session/user_session_store.dart';
import '../../../../core/themes/shared_platform_colors.dart';
import '../../../auth/data/models/login_response_model.dart';

class ProfileSummaryCard extends StatelessWidget {
  const ProfileSummaryCard({
    super.key,
    required this.params,
    required this.onEditTap,
  });
  final LoggedInUserModel params;
  final VoidCallback onEditTap;

  @override
  Widget build(
    BuildContext context,
  ) => ValueListenableBuilder<LoggedInUserModel?>(
    valueListenable: UserSessionStore.userNotifier,
    builder: (context, user, _) {
      final resolved = user ?? params;
      final name = (resolved.name ?? '').trim();
      final phone = (resolved.phone ?? '').trim();
      final image =
          (resolved.primaryImage?.url ?? params.primaryImage?.url ?? '').trim();
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE7EBF0)),
        ),
        child: Row(
          children: [
            ClipOval(
              child: image.isNotEmpty
                  ? Image.network(
                      image,
                      width: 58,
                      height: 58,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox(
                        width: 58, height: 58,
                        child: Icon(Icons.person_outline_rounded,
                          color: SharedPlatformColors.primary, size: 30),
                      ),
                    )
                  : Container(
                      width: 58,
                      height: 58,
                      alignment: Alignment.center,
                      color: const Color(0xFFF0F2FA),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        size: 30,
                        color: SharedPlatformColors.primary,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isEmpty ? 'مستخدم التطبيق' : name,
                    style: const TextStyle(
                      color: SharedPlatformColors.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (phone.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    PhoneNumberText(
                      phone: phone.formatAsPhoneNumber,
                      style: const TextStyle(
                        color: SharedPlatformColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              onPressed: onEditTap,
              tooltip: 'تعديل الملف الشخصي',
              icon: const Icon(
                Icons.chevron_left_rounded,
                color: SharedPlatformColors.primary,
                size: 23,
              ),
            ),
          ],
        ),
      );
    },
  );
}

class PhoneNumberText extends StatelessWidget {
  const PhoneNumberText({
    super.key,
    required this.phone,
    this.style,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
    this.overflow,
  });
  final String phone;
  final TextStyle? style;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: ui.TextDirection.ltr,
    child: Text(
      '\u200E$phone',
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    ),
  );
}
