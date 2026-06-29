import 'package:common_package/common_package.dart';
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

  ImageProvider? get _avatarProvider {
    final url = UserSessionStore.userNotifier.value?.primaryImage?.url;
    if (url != null && url.isNotEmpty) {
      return NetworkImage(url);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final accentOrange = context.primaryContainer;
    final avatarRadius = 44.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: context.onPrimaryContainer,
        border: Border.all(color: const Color(0xffF3F4F6), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            offset: const Offset(0, 2),
            blurRadius: 10,
          ),
        ],
      ),
      width: context.width,
      padding: const EdgeInsetsDirectional.symmetric(vertical: 20),
      child: ValueListenableBuilder(
        valueListenable: UserSessionStore.userNotifier,
        builder: (context, user, _) {
          return Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: const Color(0xffE5E7EB),
                    backgroundImage: _avatarProvider,
                    child: _avatarProvider == null
                        ? Icon(
                            Icons.person,
                            size: 48,
                            color: Colors.grey.shade500,
                          )
                        : null,
                  ),
                  PositionedDirectional(
                    start: 8,
                    bottom: 4,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xff22C55E),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.onPrimaryContainer,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppText.bodyLarge(
                user?.name ?? 'مستخدم التطبيق',
                fontWeight: FontWeight.bold,
                color: context.primary,
                textAlign: TextAlign.center,
              ),
              if (user?.phone != null &&
                  (user?.phone?.isNotEmpty ?? false)) ...[
                const SizedBox(height: 6),

                PhoneNumberText(
                  phone: user?.phone?.formatAsPhoneNumber ?? '',
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 20),
              Material(
                color: accentOrange.withAlpha(26),
                borderRadius: BorderRadius.circular(999),
                child: InkWell(
                  onTap: onEditTap,
                  borderRadius: BorderRadius.circular(999),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 20,
                          color: accentOrange,
                        ),
                        const SizedBox(width: 8),
                        AppText.bodyMedium(
                          'تعديل التفاصيل الشخصية',
                          fontWeight: FontWeight.w600,
                          color: accentOrange,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class PhoneNumberText extends StatelessWidget {
  final String phone;
  final TextStyle? style;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const PhoneNumberText({
    super.key,
    required this.phone,
    this.style,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
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
