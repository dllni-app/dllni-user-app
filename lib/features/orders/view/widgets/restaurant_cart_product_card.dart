import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/extensions/extentions.dart';
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
  double get _displayTotalPrice => widget.item.totalPrice >= 0
      ? widget.item.totalPrice
      : widget.item.unitPrice * widget.item.quantity;

  double? get _originalTotalPrice {
    final original = widget.item.originalTotalPrice ??
        (widget.item.originalUnitPrice == null
            ? null
            : widget.item.originalUnitPrice! * widget.item.quantity);
    if (original == null || original <= _displayTotalPrice) return null;
    return original;
  }

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
    final originalTotal = _originalTotalPrice;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppImage.network(
            widget.item.imageUrl ?? widget.item.name ?? '',
            loadingBuilder: (context) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: const Center(child: Icon(Icons.error)),
            width: 76,
            height: 76,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bodyLarge(
                  widget.item.name ?? '-',
                  color: const Color(0xff1F2937),
                  fontWeight: FontWeight.bold,
                  maxLines: 2,
                ),
                const SizedBox(height: 2),
                AppText.labelMedium(
                  'ملاحظات: ${widget.item.note ?? '-'}',
                  fontWeight: FontWeight.w400,
                  color: const Color(0xff6B7280),
                  maxLines: 1,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (originalTotal != null)
                          Text(
                            originalTotal.formatMoney(),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xff9CA3AF),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        AppText.bodyMedium(
                          _displayTotalPrice.formatMoney(),
                          fontWeight: FontWeight.bold,
                          color: originalTotal != null
                              ? const Color(0xff059669)
                              : const Color(0xff1A237E),
                        ),
                        if (originalTotal != null)
                          AppText.labelMedium(
                            'وفر ${(originalTotal - _displayTotalPrice).formatMoney()}',
                            color: const Color(0xff059669),
                            fontWeight: FontWeight.w700,
                          ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xffF9FAFB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xffD1D5DB)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            constraints: const BoxConstraints.tightFor(
                              width: 32,
                              height: 32,
                            ),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            onPressed: widget.isMutating
                                ? null
                                : () => _updateQuantity(widget.item.quantity + 1),
                            icon: const Icon(
                              Icons.add,
                              color: Color(0xff1A237E),
                              size: 15,
                            ),
                          ),
                          AppText.labelMedium(
                            '${widget.item.quantity}',
                            color: const Color(0xff1A237E),
                            fontWeight: FontWeight.bold,
                          ),
                          IconButton(
                            constraints: const BoxConstraints.tightFor(
                              width: 32,
                              height: 32,
                            ),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
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
                    const SizedBox(width: 4),
                    IconButton(
                      tooltip: 'حذف',
                      constraints: const BoxConstraints.tightFor(
                        width: 34,
                        height: 34,
                      ),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      onPressed: widget.isMutating ? null : widget.onDelete,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Color(0xffEF4444),
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
