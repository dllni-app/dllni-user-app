import 'dart:ui' as ui;

import 'package:dllni_user_app/core/extensions/extentions.dart';
import 'package:flutter/material.dart';

import '../../../../core/session/user_session_store.dart';
import '../../../auth/data/models/login_response_model.dart';

class ProfileSummaryCard extends StatelessWidget {
  const ProfileSummaryCard({
    super.key,
    required this.params,
    required this.onEditTap,
  });

  final LoggedInUserModel params;
  final VoidCallback onEditTap;

  ImageProvider? _avatarProvider(LoggedInUserModel? user) {
    final url = user?.primaryImage?.url ?? params.primaryImage?.url;
    if (url != null && url.trim().isNotEmpty) return NetworkImage(url);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<LoggedInUserModel?>(
      valueListenable: UserSessionStore.userNotifier,
      builder: (context, user, _) {
        final resolvedUser = user ?? params;
        final avatar = _avatarProvider(resolvedUser);
        final name = resolvedUser.name?.trim();
        final phone = resolvedUser.phone?.trim();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE4E7EC)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(6),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Color(0xFFE9F9FA),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 34,
                  backgroundColor: const Color(0xFFF2F4F7),
                  backgroundImage: avatar,
                  child: avatar == null
                      ? const Icon(
                          Icons.person_outline_rounded,
                          size: 34,
                          color: Color(0xFF667085),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name == null || name.isEmpty ? 'مستخدم التطبيق' : name,
                      style: const TextStyle(
                        color: Color(0xFF172033),
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (phone != null && phone.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      PhoneNumberText(
                        phone: phone.formatAsPhoneNumber,
                        style: const TextStyle(
                          color: Color(0xFF667085),
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: onEditTap,
                      icon: const Icon(Icons.edit_outlined, size: 17),
                      label: const Text('تعديل البيانات'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1E2A78),
                        side: const BorderSide(color: Color(0xFFBFC5E5)),
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
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
  Widget build(BuildContext context) {
    return Directionality(
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
}
