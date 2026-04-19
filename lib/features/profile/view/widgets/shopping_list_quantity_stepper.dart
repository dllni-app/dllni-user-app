import 'dart:async';
import 'dart:ui' as ui;

import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/themes/app_colors.dart';
import '../../data/models/shopping_lists_api_models.dart';
import '../manager/bloc/profile_bloc.dart';

String formatShoppingListQuantity(double q) {
  if (q == q.roundToDouble()) return q.toInt().toString();
  return q.toString();
}

class ShoppingListDetailProductRow extends StatefulWidget {
  static const double minQuantity = 1;
  final int shoppingListId;

  final ShoppingListItemModel item;

  const ShoppingListDetailProductRow({super.key, required this.shoppingListId, required this.item});

  @override
  State<ShoppingListDetailProductRow> createState() => _ShoppingListDetailProductRowState();
}

/// Minus / plus icon buttons with quantity label (no loading state).
class ShoppingListQuantityStepper extends StatelessWidget {
  final num quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final bool canDecrement;
  final bool canIncrement;

  const ShoppingListQuantityStepper({
    super.key,
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
    this.canDecrement = true,
    this.canIncrement = true,
  });

  @override
  Widget build(BuildContext context) {
    final label = formatShoppingListQuantity(quantity.toDouble());

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepIcon(icon: Icons.remove, onTap: canDecrement ? onDecrement : null),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: AppText(
            label,
            textDirection: ui.TextDirection.ltr,
            style: const TextStyle(fontSize: 16, color: Color(0xFF111827), fontWeight: FontWeight.w700, height: 24 / 16),
          ),
        ),
        _StepIcon(icon: Icons.add, onTap: canIncrement ? onIncrement : null),
      ],
    );
  }
}

class _ShoppingListDetailProductRowState extends State<ShoppingListDetailProductRow> {
  late double _displayQty;
  Timer? _debounce;

  @override
  Widget build(BuildContext context) {
    final canDecrement = _displayQty > ShoppingListDetailProductRow.minQuantity;

    return Row(
      spacing: 12,
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: .13), borderRadius: BorderRadius.circular(12)),
          child: FaIcon(FontAwesomeIcons.basketShopping, color: AppColors.primary, size: 20),
        ),
        Expanded(
          child: AppText(
            widget.item.name,
            textAlign: TextAlign.start,
            style: const TextStyle(fontSize: 16, color: Color(0xFF111827), fontWeight: FontWeight.w700, height: 24 / 16),
          ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          icon: const Icon(Icons.delete_outline, size: 22, color: Color(0xFF9CA3AF)),
          onPressed: () => _deleteItem(context),
        ),
        ShoppingListQuantityStepper(
          quantity: _displayQty,
          canDecrement: canDecrement,
          onDecrement: () => _decrement(context),
          onIncrement: () => _increment(context),
        ),
      ],
    );
  }

  @override
  void didUpdateWidget(ShoppingListDetailProductRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id == widget.item.id && oldWidget.item.quantity != widget.item.quantity) {
      _displayQty = widget.item.quantity;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _displayQty = widget.item.quantity;
  }

  void _deleteItem(BuildContext context) {
    _debounce?.cancel();
    context.read<ProfileBloc>().add(DeleteShoppingListItemEvent(shoppingListId: widget.shoppingListId, itemId: widget.item.id, context: context));
  }

  void _decrement(BuildContext context) {
    if (_displayQty <= ShoppingListDetailProductRow.minQuantity) return;
    setState(() {
      _displayQty = _displayQty - 1;
      if (_displayQty < ShoppingListDetailProductRow.minQuantity) {
        _displayQty = ShoppingListDetailProductRow.minQuantity;
      }
    });
    _schedulePatch(context);
  }

  void _increment(BuildContext context) {
    setState(() {
      _displayQty = _displayQty + 1;
    });
    _schedulePatch(context);
  }

  void _schedulePatch(BuildContext context) {
    _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: 500), () {
      if (!mounted) return;
      context.read<ProfileBloc>().add(
        PatchShoppingListItemQuantityEvent(shoppingListId: widget.shoppingListId, itemId: widget.item.id, quantity: _displayQty),
      );
    });
  }
}

class _StepIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepIcon({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: AppColors.primary.withValues(alpha: enabled ? 0.13 : 0.06),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 18, color: enabled ? AppColors.primary : const Color(0xFF9CA3AF)),
        ),
      ),
    );
  }
}
