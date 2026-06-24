import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/orders_api_models.dart';
import '../manager/bloc/orders_bloc.dart';

class RestaurantCartProductCard extends StatefulWidget {
  const RestaurantCartProductCard({
    super.key,
    required this.item,
    required this.cartId,
    required this.onDelete,
    required this.isMutating,
    required this.money,
    this.isStore = false,
  });

  final RestaurantCartItemModel item;
  final int? cartId;
  final VoidCallback onDelete;
  final bool isMutating;
  final String Function(double) money;
  final bool isStore;

  @override
  State<RestaurantCartProductCard> createState() =>
      _RestaurantCartProductCardState();
}

class _RestaurantCartProductCardState extends State<RestaurantCartProductCard> {
  void _updateQuantity(int quantity) {
    final cartId = widget.cartId;
    final itemId = widget.item.id;
    if (cartId == null || itemId == null) return;

    final event = widget.isStore
        ? UpdateStoreCartItemEvent(
            cartId: cartId,
            itemId: itemId,
            quantity: quantity,
          )
        : UpdateRestaurantCartItemEvent(
            cartId: cartId,
            itemId: itemId,
            quantity: quantity,
          );

    context.read<OrdersBloc>().add(event);
  }

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
              AppImage.network(
                widget.item.imageUrl ?? widget.item.name ?? '',
                loadingBuilder: (context) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: const Center(child: Icon(Icons.error)),
                width: 96,
                height: 96,
                borderRadius: BorderRadius.circular(14),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.titleMedium(
                      widget.item.name ?? '-',
                      color: const Color(0xff1F2937),
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 4),
                    AppText.labelLarge(
                      'الإضافات: ${widget.item.note ?? '-'}',
                      fontWeight: FontWeight.w400,
                      color: const Color(0xff6B7280),
                    ),
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
                          : () => _updateQuantity(widget.item.quantity + 1),
                      icon: const Icon(
                        Icons.add,
                        color: Color(0xff1A237E),
                        size: 15,
                      ),
                    ),
                    AppText.labelLarge(
                      '${widget.item.quantity}',
                      color: const Color(0xff1A237E),
                      fontWeight: FontWeight.bold,
                    ),
                    IconButton(
                      onPressed: widget.isMutating || widget.item.quantity <= 1
                          ? null
                          : () => _updateQuantity(widget.item.quantity - 1),
                      icon: const Icon(
                        Icons.remove,
                        color: Color(0xff1A237E),
                        size: 15,
                      ),
                    ),
                  ],
                ),
              ),
              AppText.bodyLarge(
                widget.money(widget.item.totalPrice),
                fontWeight: FontWeight.bold,
                color: const Color(0xff1A237E),
              ),
            ],
          ),
          TextButton.icon(
            onPressed: widget.isMutating ? null : widget.onDelete,
            icon: const Icon(
              Icons.delete_outline,
              color: Color(0xffEF4444),
              size: 15,
            ),
            label: AppText.labelLarge(
              'حذف',
              color: const Color(0xffEF4444),
            ),
          ),
        ],
      ),
    );
  }
}
