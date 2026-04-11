import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../data/models/orders_api_models.dart';

class RestaurantCartProductCard extends StatefulWidget {
  const RestaurantCartProductCard({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onEdit,
    required this.isMutating,
    required this.money,
  });

  final RestaurantCartItemModel item;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final bool isMutating;
  final String Function(double) money;

  @override
  State<RestaurantCartProductCard> createState() => _RestaurantCartProductCardState();
}

class _RestaurantCartProductCardState extends State<RestaurantCartProductCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(color: const Color(0xffF3F4F6), borderRadius: BorderRadius.circular(14)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.titleMedium(widget.item.name ?? '-', color: const Color(0xff1F2937), fontWeight: FontWeight.bold),
                    const SizedBox(height: 4),
                    AppText.labelLarge('الإضافات: ${widget.item.note ?? '-'}', fontWeight: FontWeight.w400, color: const Color(0xff6B7280)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xffF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xffD1D5DB)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: widget.isMutating
                          ? null
                          : () {
                              if (widget.item.id == null) return;
                              setState(() {
                                widget.item.quantity++;
                              });
                            },
                      icon: const Icon(Icons.add, color: Color(0xff1A237E), size: 15),
                    ),
                    AppText.labelLarge('${widget.item.quantity}', color: const Color(0xff1A237E), fontWeight: FontWeight.bold),
                    IconButton(
                      onPressed: widget.isMutating
                          ? null
                          : () {
                              if (widget.item.quantity <= 1) return;
                              setState(() {
                                widget.item.quantity--;
                              });
                            },
                      icon: const Icon(Icons.remove, color: Color(0xff1A237E), size: 15),
                    ),
                  ],
                ),
              ),
              AppText.bodyLarge(widget.money(widget.item.totalPrice), fontWeight: FontWeight.bold, color: const Color(0xff1A237E)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: widget.isMutating ? null : widget.onDelete,
                icon: const Icon(Icons.delete_outline, color: Color(0xffEF4444), size: 15),
                label: AppText.labelLarge('حذف', color: const Color(0xffEF4444)),
              ),
              const SizedBox(width: 14),
              TextButton.icon(
                onPressed: widget.isMutating ? null : widget.onEdit,
                icon: const Icon(Icons.edit, color: Color(0xff1E2A78), size: 15),
                label: AppText.labelLarge('تعديل', color: const Color(0xff1E2A78)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
