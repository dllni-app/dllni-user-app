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

  IconData get _addressTypeIcon => switch (item.type) {
    AddressType.home => Icons.home_outlined,
    AddressType.work => Icons.work_outline_rounded,
    AddressType.family => Icons.people_outline_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDefault
                  ? const Color(0xFF1E2A78)
                  : const Color(0xFFE4E7EC),
              width: isDefault ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF0FA),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _addressTypeIcon,
                      color: const Color(0xFF1E2A78),
                      size: 22,
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
                                  color: Color(0xFF172033),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            if (isDefault)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF0FA),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  'افتراضي',
                                  style: TextStyle(
                                    color: Color(0xFF1E2A78),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Text(
                          item.line1,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            color: Color(0xFF667085),
                            fontSize: 13,
                            height: 1.45,
                          ),
                        ),
                        if (item.landmark != null &&
                            item.landmark!.trim().isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.notes_rounded,
                                size: 15,
                                color: Color(0xFF98A2B3),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  item.landmark!,
                                  style: const TextStyle(
                                    color: Color(0xFF98A2B3),
                                    fontSize: 12,
                                  ),
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
                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFEAECF0)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    if (!isDefault)
                      _AddressAction(
                        label: 'تعيين كافتراضي',
                        icon: Icons.star_outline_rounded,
                        color: const Color(0xFF1E2A78),
                        onTap: onSetDefault,
                      ),
                    _AddressAction(
                      label: 'تعديل',
                      icon: Icons.edit_outlined,
                      color: const Color(0xFF475467),
                      onTap: onEdit,
                    ),
                    _AddressAction(
                      label: 'حذف',
                      icon: Icons.delete_outline_rounded,
                      color: const Color(0xFFD92D20),
                      onTap: onDelete,
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 12),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'اختيار هذا العنوان',
                      style: TextStyle(
                        color: Color(0xFF1E2A78),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 5),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 17,
                      color: Color(0xFF1E2A78),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressAction extends StatelessWidget {
  const _AddressAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: color,
        minimumSize: const Size(44, 40),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        visualDensity: VisualDensity.compact,
      ),
      icon: Icon(icon, size: 17),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}
