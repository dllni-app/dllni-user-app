import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_pickers.dart';
import '../../data/models/orders_api_models.dart';
import '../manager/bloc/orders_bloc.dart';
import '../screens/restaurant_order_fulfillment_screen.dart';
import 'restaurant_cart_add_more_products_button.dart';
import 'restaurant_cart_checkout_fulfillment_button.dart';
import 'restaurant_cart_coupon_section.dart';
import 'restaurant_cart_empty_view.dart';
import 'restaurant_cart_load_failed_view.dart';
import 'restaurant_cart_order_notes_section.dart';
import 'restaurant_cart_order_summary_section.dart';
import 'restaurant_cart_product_card.dart';

class SupermarketCartCheckoutBody extends StatefulWidget {
  const SupermarketCartCheckoutBody({super.key, required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  State<SupermarketCartCheckoutBody> createState() => _SupermarketCartCheckoutBodyState();
}

class _SupermarketCartCheckoutBodyState extends State<SupermarketCartCheckoutBody> {
  final TextEditingController _couponController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _notesController.text = context.read<OrdersBloc>().state.cartNote;
  }

  @override
  void dispose() {
    _couponController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _money(double value) => '${value.toStringAsFixed(0)} ل.س';

  String _couponUnavailableMessage(CouponCheckDataModel? couponData) {
    switch (couponData?.reason) {
      case 'not_found':
        return 'الكوبون غير موجود.';
      case 'expired':
        return 'انتهت صلاحية هذا الكوبون.';
      case 'not_available':
        return 'هذا الكوبون غير متاح حالياً.';
      default:
        return 'لا يمكن استخدام هذا الكوبون.';
    }
  }

  Future<void> _pickSchedule(BuildContext context) async {
    final selectedDate = await AppPickers.showAppDatePicker(context: context);
    if (!context.mounted) return;
    context.read<OrdersBloc>().add(StoreScheduledAtChangedEvent(scheduledAt: selectedDate));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersBloc, OrdersState>(
      buildWhen: (p, c) =>
          p.storeCartStatus != c.storeCartStatus ||
          p.storeCart != c.storeCart ||
          p.storeCartErrorMessage != c.storeCartErrorMessage ||
          p.storeCouponStatus != c.storeCouponStatus ||
          p.storeCouponData != c.storeCouponData ||
          p.cartNote != c.cartNote ||
          p.storeReceiveMode != c.storeReceiveMode ||
          p.storeScheduledAt != c.storeScheduledAt ||
          p.isMutatingStoreCartItem != c.isMutatingStoreCartItem,
      builder: (context, state) {
        final cart = state.storeCart;
        final loading = state.storeCartStatus == BlocStatus.loading;
        final failed = state.storeCartStatus == BlocStatus.failed;
        final hasCart = cart != null && cart.items.isNotEmpty;
        final subtotal = state.storeCouponData?.amounts?.subtotal ?? cart?.amounts?.subtotal ?? 0;
        final discount = state.storeCouponData?.amounts?.discount ?? (subtotal - (cart?.amounts?.total ?? 0));
        final total = state.storeCouponData?.amounts?.total ?? cart?.amounts?.total ?? 0;
        final isScheduled = state.storeReceiveMode == 'scheduled';

        if (loading && cart == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (failed && cart == null) {
          return RestaurantCartLoadFailedView(
            errorMessage: state.storeCartErrorMessage,
            onRetry: () => context.read<OrdersBloc>().add(FetchStoreCartEvent()),
          );
        }
        if (!hasCart) {
          return RestaurantCartEmptyView(onRefresh: widget.onRefresh, isStore: true,);
        }

        final data = cart;
        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: widget.onRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 20),
                children: [
                  ...data.items.map(
                    (item) => Padding(
                      padding: const EdgeInsetsDirectional.only(bottom: 12),
                      child: RestaurantCartProductCard(
                        item: item,
                        isMutating: state.isMutatingStoreCartItem,
                        onDelete: () {
                          if (item.id == null) return;
                          context.read<OrdersBloc>().add(DeleteStoreCartItemEvent(itemId: item.id!));
                        },
                        onEdit: () {
                          if (item.id == null) return;
                          context.read<OrdersBloc>().add(UpdateStoreCartItemEvent(itemId: item.id!, quantity: item.quantity + 1));
                        },
                        money: _money,
                      ),
                    ),
                  ),
                  const RestaurantCartAddMoreProductsButton(isRestaurant: false),
                  const SizedBox(height: 12),
                  RestaurantCartCouponSection(
                    couponController: _couponController,
                    state: state,
                    discount: discount,
                    money: _money,
                    couponUnavailableMessage: _couponUnavailableMessage,
                    applyEventBuilder: (code) => ApplyStoreCouponEvent(couponCode: code),
                    couponStatusSelector: (s) => s.storeCouponStatus,
                    couponDataSelector: (s) => s.storeCouponData,
                    couponErrorSelector: (s) => s.storeCouponErrorMessage,
                  ),
                  const SizedBox(height: 12),
                  RestaurantCartOrderNotesSection(
                    notesController: _notesController,
                    onChanged: (value) => context.read<OrdersBloc>().add(CartNoteChangedEvent(note: value)),
                  ),
                  const SizedBox(height: 12),
                  _ReceiveModeSection(
                    isScheduled: isScheduled,
                    scheduledLabel: state.storeScheduledAt,
                    onImmediate: () => context.read<OrdersBloc>().add(StoreReceiveModeChangedEvent(receiveMode: 'immediate')),
                    onScheduled: () => context.read<OrdersBloc>().add(StoreReceiveModeChangedEvent(receiveMode: 'scheduled')),
                    onPickSchedule: () => _pickSchedule(context),
                  ),
                  const SizedBox(height: 12),
                  RestaurantCartOrderSummarySection(
                    itemsCount: data.items.length,
                    subtotal: subtotal,
                    discount: discount,
                    total: total,
                    money: _money,
                  ),
                  const SizedBox(height: 16),
                  RestaurantCartCheckoutFulfillmentButton(
                    onTap: () {
                      context.pushRoute(
                        '/restaurant-order-fulfillment',
                        arguments: RestaurantOrderFulfillmentArgs(bloc: context.read<OrdersBloc>(), cartId: data.id, section: 'supermarket'),
                      );
                    },
                  ),
                ],
              ),
            ),
            if (loading) const Positioned(top: 0, left: 0, right: 0, child: LinearProgressIndicator(minHeight: 2)),
          ],
        );
      },
    );
  }
}

class _ReceiveModeSection extends StatelessWidget {
  const _ReceiveModeSection({
    required this.isScheduled,
    required this.scheduledLabel,
    required this.onImmediate,
    required this.onScheduled,
    required this.onPickSchedule,
  });

  final bool isScheduled;
  final String? scheduledLabel;
  final VoidCallback onImmediate;
  final VoidCallback onScheduled;
  final VoidCallback onPickSchedule;

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'وقت الاستلام',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xff1F2937)),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(color: const Color(0xffF3F4F6), borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onScheduled,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isScheduled ? const Color(0xffFF7A00) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'طلب مجدول',
                        style: TextStyle(fontWeight: FontWeight.w700, color: isScheduled ? Colors.white : const Color(0xff111827)),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: onImmediate,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: !isScheduled ? const Color(0xffFF7A00) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'بأسرع وقت',
                        style: TextStyle(fontWeight: FontWeight.w700, color: !isScheduled ? Colors.white : const Color(0xff111827)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isScheduled) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onPickSchedule,
              icon: const Icon(Icons.calendar_today_rounded, size: 16),
              label: Text(scheduledLabel ?? 'اختر تاريخ التوصيل'),
            ),
          ],
        ],
      ),
    );
  }
}
