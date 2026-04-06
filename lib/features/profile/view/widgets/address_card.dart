import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../domain/models/address_list_item.dart';

class AddressCard extends StatelessWidget {
  const AddressCard({
    super.key,
    required this.item,
    required this.isDefault,
    this.onSetDefault,
    this.onEdit,
    this.onDelete,
    this.onTap,
    this.showActions = true,
  });

  final AddressListItem item;
  final bool isDefault;
  final VoidCallback? onSetDefault;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final bool showActions;

  static const _borderColor = Color(0xffE5E7EB);
  static const _subtitleColor = Color(0xff6B7280);
  static const _dangerColor = Color(0xffEF4444);

  IconData get _addressTypeIcon {
    switch (item.type) {
      case AddressType.home:
        return Icons.home_filled;
      case AddressType.work:
        return Icons.work;
      case AddressType.family:
        return Icons.location_on;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: context.onPrimaryContainer,
          border: Border(
            right: !isDefault
                ? BorderSide.none
                : BorderSide(color: context.primaryContainer, width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              offset: const Offset(0, 2),
              blurRadius: 4,
              spreadRadius: -1,
            ),
            BoxShadow(
              color: Colors.black.withAlpha(12),
              offset: const Offset(0, 4),
              blurRadius: 6,
              spreadRadius: -1,
            ),
          ],
        ),
        padding: EdgeInsetsDirectional.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xffF3F4F6),
                  child: Icon(
                    _addressTypeIcon,
                    size: 18,
                    color: context.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppText.bodyMedium(
                            item.label,
                            color: context.primary,
                            fontWeight: FontWeight.w700,
                          ),
                          if (isDefault) ...[
                            Container(
                              decoration: BoxDecoration(
                                color: context.primaryContainer.withAlpha(36),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsetsDirectional.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 12,
                                    color: context.primaryContainer,
                                  ),
                                  const SizedBox(width: 4),
                                  AppText.labelSmall(
                                    'افتراضي',
                                    color: context.primaryContainer,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      AppText.bodyMedium(
                        item.line1,
                        color: _subtitleColor,
                        textAlign: TextAlign.start,
                      ),
                      if (item.landmark != null &&
                          item.landmark!.trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.sticky_note_2_outlined,
                              size: 14,
                              color: _subtitleColor,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: AppText.bodySmall(
                                item.landmark!,
                                color: _subtitleColor,
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (showActions) ...[
              const SizedBox(height: 12),
              const Divider(color: _borderColor, thickness: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (!isDefault)
                    _ActionButton(
                      label: 'تعيين كافتراضي',
                      color: context.primaryContainer,
                      onTap: onSetDefault,
                    ),
                  const Spacer(),
                  _ActionButton(
                    label: 'تعديل',
                    icon: Icons.edit_outlined,
                    color: _subtitleColor,
                    onTap: onEdit,
                  ),
                  const SizedBox(width: 20),
                  _ActionButton(
                    label: 'حذف',
                    icon: Icons.delete_outline,
                    color: _dangerColor,
                    onTap: onDelete,
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 10),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: AppText.labelLarge(
                  'اختيار هذا العنوان',
                  color: context.primaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    this.icon,
    this.onTap,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 2,
          vertical: 2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 4),
            ],
            AppText.labelLarge(
              label,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }
}
