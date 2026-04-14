import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../data/models/fetch_restaurant_product_details_model.dart';


class ProductActionButton extends StatelessWidget {
  const ProductActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconColor = const Color(0xFF1F2937),
  });

  final IconData icon;
  final void Function() onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsetsDirectional.all(10),
        decoration: BoxDecoration(color: Color(0xFFF9FAFB), borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Icon(icon, size: 20, color: iconColor),
      ),
    );
  }
}

class ProductBadge extends StatelessWidget {
  const ProductBadge({super.key, required this.title, required this.color});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(offset: Offset(0, 2), blurRadius: 8, color: Color(0x1A000000))],
      ),
      child: AppText(
        title,
        style: TextStyle(color: context.onPrimary, fontSize: 11, fontWeight: FontWeight.w700, height: 16 / 11),
      ),
    );
  }
}

class ProductModifierGroupCard extends StatelessWidget {
  const ProductModifierGroupCard({
    super.key,
    required this.group,
    required this.selectedModifierIds,
    required this.onModifierTap,
  });

  final RestaurantProductDetailsModifierGroup group;
  final Set<int> selectedModifierIds;
  final void Function(int modifierId) onModifierTap;

  @override
  Widget build(BuildContext context) {
    final maxText = group.maxSelections > 0 ? '${group.maxSelections}' : 'غير محدد';
    final minText = group.minSelections > 0 ? '${group.minSelections}' : '0';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: context.onPrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            group.name ?? 'إضافات',
            style: TextStyle(color: Color(0xFF111827), fontSize: 15, fontWeight: FontWeight.w700, height: 20 / 15),
          ),
          SizedBox(height: 2),
          AppText(
            group.isRequired ? 'مطلوب - اختر من $minText إلى $maxText' : 'اختياري - حتى $maxText',
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12, fontWeight: FontWeight.w500, height: 18 / 12),
          ),
          SizedBox(height: 10),
          ...group.modifiers.map((modifier) {
            final modifierId = modifier.id;
            if (modifierId == null) return const SizedBox.shrink();
            final isSelected = selectedModifierIds.contains(modifierId);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => onModifierTap(modifierId),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xFFFFF7ED) : Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSelected ? Color(0xFFFF7A00) : Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle : (group.maxSelections <= 1 ? Icons.radio_button_unchecked : Icons.check_box_outline_blank),
                        color: isSelected ? Color(0xFFFF7A00) : Color(0xFF9CA3AF),
                        size: 18,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: AppText(
                          modifier.name ?? 'إضافة',
                          style: TextStyle(color: Color(0xFF111827), fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                      AppText(
                        modifierPriceText(modifier.price),
                        style: TextStyle(color: Color(0xFF111827), fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

String modifierPriceText(num? price) {
  if (price == null || price == 0) return '+0 ل.س';
  return '+$price ل.س';
}

class ProductSavedNoteChip extends StatelessWidget {
  const ProductSavedNoteChip({super.key, required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            label,
            style: TextStyle(color: Color(0xFF4B5563), fontSize: 12, fontWeight: FontWeight.w600, height: 16 / 12),
          ),
          SizedBox(width: 6),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(10),
            child: Icon(Icons.close, size: 14, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

class ProductBottomBar extends StatelessWidget {
  const ProductBottomBar({
    super.key,
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
    required this.onAddPressed,
    this.isSubmitting = false,
  });

  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onAddPressed;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: context.onPrimary,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            spacing: 30,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ProductCircleCounterButton(icon: FontAwesomeIcons.minus, color: Color(0xFFF3F4F6), iconColor: Color(0xFF6B7280), onTap: onDecrease),
              AppText(
                quantity.toString(),
                style: TextStyle(color: Color(0xFF111827), fontSize: 36 / 2, fontWeight: FontWeight.w700, height: 28 / 18),
              ),
              ProductCircleCounterButton(icon: FontAwesomeIcons.plus, color: Color(0xFFFF7A00), iconColor: Colors.white, onTap: onIncrease),
            ],
          ),
          SizedBox(height: 12),
          InkWell(
            onTap: isSubmitting ? null : onAddPressed,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: Color(0xFFFF7A00), borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(FontAwesomeIcons.cartShopping, size: 13, color: context.onPrimary),
                  SizedBox(width: 8),
                  AppText(
                    isSubmitting ? "جاري الإضافة..." : "إضافة إلى السلة",
                    style: TextStyle(color: context.onPrimary, fontSize: 16, fontWeight: FontWeight.w700, height: 24 / 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCircleCounterButton extends StatelessWidget {
  const ProductCircleCounterButton({
    super.key,
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  final FaIconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 11, vertical: 10),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
        child: FaIcon(icon, size: 12, color: iconColor),
      ),
    );
  }
}
