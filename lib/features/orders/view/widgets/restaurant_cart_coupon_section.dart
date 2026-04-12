import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/orders_api_models.dart';
import '../manager/bloc/orders_bloc.dart';
import 'restaurant_cart_card_wrapper.dart';

class RestaurantCartCouponSection extends StatelessWidget {
  const RestaurantCartCouponSection({
    super.key,
    required this.couponController,
    required this.state,
    required this.discount,
    required this.money,
    required this.couponUnavailableMessage,
    this.applyEventBuilder,
    this.couponStatusSelector,
    this.couponDataSelector,
    this.couponErrorSelector,
  });

  final TextEditingController couponController;
  final OrdersState state;
  final double discount;
  final String Function(double) money;
  final String Function(CouponCheckDataModel?) couponUnavailableMessage;
  final OrdersEvent Function(String couponCode)? applyEventBuilder;
  final BlocStatus? Function(OrdersState state)? couponStatusSelector;
  final CouponCheckDataModel? Function(OrdersState state)? couponDataSelector;
  final String? Function(OrdersState state)? couponErrorSelector;

  @override
  Widget build(BuildContext context) {
    final couponStatus = couponStatusSelector?.call(state) ?? state.couponStatus;
    final couponData = couponDataSelector?.call(state) ?? state.couponData;
    final couponErrorMessage =
        couponErrorSelector?.call(state) ?? state.couponErrorMessage;
    final eventBuilder = applyEventBuilder ?? (code) => ApplyRestaurantCouponEvent(couponCode: code);

    return RestaurantCartCardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AppImage.asset(Assets.images.rsProfileCoupon.path, color: context.primaryContainer),
              const SizedBox(width: 6),
              AppText.bodyLarge('هل لديك كود خصم؟', fontWeight: FontWeight.bold),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: couponController,
                  style: const TextStyle(color: Color(0xff9CA3AF), fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'أدخل كود الخصم هنا',
                    filled: true,
                    hintStyle: const TextStyle(color: Color(0xff9CA3AF), fontSize: 14),
                    fillColor: const Color(0xffF3F4F6),
                    contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: couponStatus == BlocStatus.loading
                    ? null
                    : () {
                        final code = couponController.text.trim();
                        if (code.isEmpty) return;
                        context.read<OrdersBloc>().add(eventBuilder(code));
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff1E2A78),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsetsDirectional.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: couponStatus == BlocStatus.loading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : AppText.labelLarge('تطبيق', color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (couponData?.isAvailable == true) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xffECFDF3), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xff10B981), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppText.labelLarge(
                      'تم تطبيق الكوبون بنجاح: خصم ${money(discount)}',
                      color: const Color(0xff10B981),
                      textAlign: TextAlign.start,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (couponStatus == BlocStatus.success &&
              couponData?.isAvailable == false) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xffFEF2F2), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Color(0xffEF4444), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppText.labelLarge(
                      couponUnavailableMessage(couponData),
                      color: const Color(0xffB91C1C),
                      textAlign: TextAlign.start,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (couponStatus == BlocStatus.failed) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xffFEF2F2), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Color(0xffEF4444), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppText.labelLarge(
                      couponErrorMessage ?? 'تعذر التحقق من الكوبون حالياً.',
                      color: const Color(0xffB91C1C),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
