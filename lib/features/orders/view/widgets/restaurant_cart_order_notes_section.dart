import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import 'restaurant_cart_card_wrapper.dart';

class RestaurantCartOrderNotesSection extends StatelessWidget {
  const RestaurantCartOrderNotesSection({
    super.key,
    required this.notesController,
    required this.onChanged,
  });

  final TextEditingController notesController;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return RestaurantCartCardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.chat_bubble_outline, size: 18, color: Color(0xff6B7280)),
              const SizedBox(width: 6),
              AppText.bodyLarge('ملاحظات الطلب', fontWeight: FontWeight.bold),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: notesController,
            maxLines: 3,
            style: const TextStyle(color: Color(0xff9CA3AF), fontSize: 14),
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'ملاحظات إضافية للمطعم (اختياري)...',
              filled: true,
              hintStyle: const TextStyle(color: Color(0xff9CA3AF), fontSize: 14),
              fillColor: const Color(0xffF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xffE5E7EB)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
