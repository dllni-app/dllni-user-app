import 'package:flutter/material.dart';
import '../../../../core/themes/shared_platform_colors.dart';
import '../../domain/models/address_list_item.dart';

/// Address choice in Alnadha V7, independent of the old profile card.
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
  final VoidCallback? onSetDefault, onEdit, onDelete, onTap;
  final bool showActions;

  IconData get _icon => switch (item.type) {
    AddressType.home => Icons.home_outlined,
    AddressType.work => Icons.business_outlined,
    AddressType.family => Icons.people_outline,
  };

  @override
  Widget build(BuildContext context) {
    final selected = isDefault;
    return Semantics(
      button: onTap != null,
      selected: selected,
      label: [
        item.label,
        item.line1,
        if (selected) 'العنوان الافتراضي',
      ].join('، '),
      child: Container(
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE9F9FA) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            width: selected ? 1.6 : 1,
            color: selected
                ? SharedPlatformColors.cleaning
                : const Color(0xFFE7EBF0),
          ),
        ),
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 84),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected
                                ? Colors.white
                                : const Color(0xFFF0F3F9),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Icon(
                            _icon,
                            size: 22,
                            color: SharedPlatformColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.label,
                                      style: const TextStyle(
                                        color: SharedPlatformColors.primary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  if (selected)
                                    const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_circle_rounded,
                                          color: Color(0xFF088895),
                                          size: 18,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          'افتراضي',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF087D88),
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (!showActions && !selected)
                                    const Icon(
                                      Icons.radio_button_off,
                                      size: 20,
                                      color: SharedPlatformColors.muted,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              if (!showActions) ...[
                                const Text(
                                  'اختيار هذا العنوان',
                                  style: TextStyle(
                                    color: Color(0xFF087D88),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 5),
                              ],
                              Text(
                                item.line1,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: SharedPlatformColors.muted,
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                              ),
                              if ((item.landmark ?? '').trim().isNotEmpty) ...[
                                const SizedBox(height: 5),
                                Text(
                                  item.landmark!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: SharedPlatformColors.muted,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (showActions) ...[
              const Divider(height: 1, color: Color(0xFFE2E8EF)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    if (!selected)
                      _Action(
                        label: 'جعله افتراضياً',
                        icon: Icons.check_circle_outline,
                        onTap: onSetDefault,
                      ),
                    const Spacer(),
                    _Action(
                      label: 'تعديل',
                      icon: Icons.edit_outlined,
                      onTap: onEdit,
                    ),
                    _Action(
                      label: 'حذف',
                      icon: Icons.delete_outline,
                      color: const Color(0xFFC2414C),
                      onTap: onDelete,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color = SharedPlatformColors.primary,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) => TextButton.icon(
    onPressed: onTap,
    icon: Icon(icon, size: 17),
    label: Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
    ),
    style: TextButton.styleFrom(
      foregroundColor: color,
      minimumSize: const Size(44, 44),
      padding: const EdgeInsets.symmetric(horizontal: 7),
    ),
  );
}
