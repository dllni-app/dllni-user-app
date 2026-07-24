import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/orders_api_models.dart';
import '../manager/bloc/merchant_checkout_coupon_bloc_extension.dart';
import '../manager/bloc/orders_bloc.dart';
import 'restaurant_cart_coupon_section.dart';

class MerchantCheckoutCouponSection extends StatefulWidget {
  const MerchantCheckoutCouponSection({
    super.key,
    required this.cartId,
    required this.section,
  });

  final int cartId;
  final String section;

  @override
  State<MerchantCheckoutCouponSection> createState() =>
      _MerchantCheckoutCouponSectionState();
}

class _MerchantCheckoutCouponSectionState
    extends State<MerchantCheckoutCouponSection> {
  final TextEditingController _couponController = TextEditingController();

  bool get _isStore => widget.section == 'supermarket';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bloc = context.read<OrdersBloc>();
      bloc.ensureMerchantCouponHandlers();
      bloc.add(ClearMerchantCartCouponEvent(section: widget.section));
    });
  }

  @override
  void didUpdateWidget(covariant MerchantCheckoutCouponSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cartId == widget.cartId &&
        oldWidget.section == widget.section) {
      return;
    }

    _couponController.clear();
    final bloc = context.read<OrdersBloc>();
    bloc.ensureMerchantCouponHandlers();
    bloc.add(ClearMerchantCartCouponEvent(section: widget.section));
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  String _money(double value) => '${value.toStringAsFixed(0)} ل.س';

  String _unavailableMessage(CouponCheckDataModel? data) {
    return switch (data?.reason) {
      'not_found' => 'رمز الكوبون غير موجود.',
      'inactive' => 'هذا الكوبون غير فعال حالياً.',
      'not_started' => 'لم يبدأ وقت استخدام هذا الكوبون بعد.',
      'expired' => 'انتهت صلاحية هذا الكوبون.',
      'wrong_section' => 'هذا الكوبون غير مخصص لهذا القسم.',
      'not_assigned_to_user' => 'هذا الكوبون غير مخصص لحسابك.',
      'global_usage_limit_reached' ||
      'usage_limit_reached' =>
        'تم الوصول إلى الحد الأقصى لاستخدام هذا الكوبون.',
      'user_usage_limit_reached' => 'لقد استخدمت هذا الكوبون مسبقاً.',
      'min_order_not_met' => 'قيمة الطلب أقل من الحد الأدنى للكوبون.',
      _ => 'لا يمكن تطبيق هذا الكوبون على الطلب الحالي.',
    };
  }

  void _clearCouponResult(String _) {
    final bloc = context.read<OrdersBloc>();
    bloc.ensureMerchantCouponHandlers();
    bloc.add(ClearMerchantCartCouponEvent(section: widget.section));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersBloc, OrdersState>(
      buildWhen: (previous, current) {
        if (_isStore) {
          return previous.storeCouponStatus != current.storeCouponStatus ||
              previous.storeCouponData != current.storeCouponData ||
              previous.storeCouponErrorMessage !=
                  current.storeCouponErrorMessage;
        }

        return previous.couponStatus != current.couponStatus ||
            previous.couponData != current.couponData ||
            previous.couponErrorMessage != current.couponErrorMessage;
      },
      builder: (context, state) {
        final couponData = _isStore
            ? state.storeCouponData
            : state.couponData;

        return RestaurantCartCouponSection(
          couponController: _couponController,
          state: state,
          discount: couponData?.amounts?.discount ?? 0,
          money: _money,
          couponUnavailableMessage: _unavailableMessage,
          applyEventBuilder: (couponCode) => ApplyMerchantCartCouponEvent(
            cartId: widget.cartId,
            section: widget.section,
            couponCode: couponCode,
          ),
          couponStatusSelector: (state) =>
              _isStore ? state.storeCouponStatus : state.couponStatus,
          couponDataSelector: (state) =>
              _isStore ? state.storeCouponData : state.couponData,
          couponErrorSelector: (state) => _isStore
              ? state.storeCouponErrorMessage
              : state.couponErrorMessage,
          onCouponChanged: _clearCouponResult,
        );
      },
    );
  }
}
