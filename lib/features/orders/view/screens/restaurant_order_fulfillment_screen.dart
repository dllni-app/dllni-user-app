import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/features/profile/domain/models/address_list_item.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_pickers.dart';
import '../manager/bloc/orders_bloc.dart';
import '../../../profile/view/widgets/personal_details_app_bar.dart';

class RestaurantOrderFulfillmentArgs {
  final OrdersBloc bloc;
  final int? cartId;
  final String section;

  RestaurantOrderFulfillmentArgs({required this.bloc, required this.cartId, required this.section});
}

@AutoRoutePage(path: '/restaurant-order-fulfillment')
class RestaurantOrderFulfillmentScreen extends StatelessWidget {
  const RestaurantOrderFulfillmentScreen({super.key, required this.args});

  final RestaurantOrderFulfillmentArgs args;

  String _money(double value) => '${value.toStringAsFixed(0)} ل.س';


  String _scheduledLabel(DateTime? value) {
    if (value == null) return 'اختر التاريخ والوقت';
    return DateFormat('yyyy/MM/dd - HH:mm', 'en').format(value);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: args.bloc,
      child: Scaffold(
        backgroundColor: const Color(0xffF3F4F6),
        body: SafeArea(
          child: BlocConsumer<OrdersBloc, OrdersState>(
            listenWhen: (previous, current) => args.section == 'supermarket'
                ? previous.placeStoreOrderStatus != current.placeStoreOrderStatus
                : previous.placeOrderStatus != current.placeOrderStatus,
            listener: (context, state) {
              final status = args.section == 'supermarket' ? state.placeStoreOrderStatus : state.placeOrderStatus;
              final errorMessage = args.section == 'supermarket' ? state.placeStoreOrderErrorMessage : state.placeOrderErrorMessage;
              if (status == BlocStatus.success) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تاكيد الطلب بنجاح')));
                context.pop(true);
              } else if (status == BlocStatus.failed) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage ?? 'تعذر تاكيد الطلب حالياً.')));
              }
            },
            builder: (context, state) {
              final isDelivery = (state.selectedFulfillmentType ?? 'delivery') == 'delivery';
              final isStoreFlow = args.section == 'supermarket';
              final isPlacingOrder = isStoreFlow ? state.placeStoreOrderStatus == BlocStatus.loading : state.placeOrderStatus == BlocStatus.loading;
              final amounts = isStoreFlow ? state.storeCart?.amounts : state.restaurantCart?.amounts;
              final couponData = isStoreFlow ? state.storeCouponData : state.couponData;
              final subtotal = couponData?.amounts?.subtotal ?? amounts?.subtotal ?? 0;
              final discount = couponData?.amounts?.discount ?? (subtotal - (amounts?.total ?? subtotal));
              final deliveryFee = isDelivery ? 0.0 : 0.0;
              final total = couponData?.amounts?.total ?? amounts?.total ?? 0;
              final isScheduled = state.storeReceiveMode == 'scheduled';
              return Column(
                children: [
                  PersonalDetailsAppBar(title: 'الطلبية الحالية'),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 20),
                      child: Column(
                        children: [
                          Center(
                            child: AppText.labelLarge('اختر الطريقة المناسبة لاستلام طلبك', color: Color(0xff6D28D9), fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 24),
                          _FulfillmentCard(
                            title: 'توصيل إلى العنوان',
                            subtitle: 'سيتم توصيل الطلب إلى موقعك',
                            icon: Icons.delivery_dining,
                            selected: isDelivery,
                            onTap: () {
                              context.read<OrdersBloc>().add(CartFulfillmentTypeChangedEvent(fulfillmentType: 'delivery'));
                            },
                          ),
                          const SizedBox(height: 24),
                          _FulfillmentCard(
                            title: isStoreFlow ? 'استلام من المتجر' : 'استلام من المطعم',
                            subtitle: 'يمكنك استلام الطلب بنفسك',
                            icon: Icons.storefront_outlined,
                            selected: !isDelivery,
                            onTap: () {
                              context.read<OrdersBloc>().add(CartFulfillmentTypeChangedEvent(fulfillmentType: 'pickup'));
                            },
                          ),
                          const SizedBox(height: 24),
                          if (isDelivery)
                            _LocationCard(
                              title: 'موقع التوصيل',
                              topAction: 'تغيير',
                              onTopAction: () async {
                                final selected = await context.pushRoute('/myaddresses', arguments: true);
                                if (!context.mounted) return;
                                if (selected is AddressListItem) {
                                  context.read<OrdersBloc>().add(CartSelectedAddressChangedEvent(address: selected));
                                }
                              },
                              line1: state.selectedAddress?.line1 ?? 'لم يتم تحديد العنوان',
                              line2: state.selectedAddress?.street ?? '',
                            )
                          else
                            _LocationCard(
                              title: isStoreFlow ? 'موقع المتجر' : 'موقع المطعم',
                              line1: isStoreFlow ? (state.storeCart?.merchant?.name ?? 'المتجر') : (state.restaurantCart?.merchant?.name ?? 'المطعم'),
                              line2: '${args.cartId ?? ''}',
                            ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xffE5E7EB)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: AppText.bodyMedium('ملخص الطلب', fontWeight: FontWeight.bold, color: Color(0xff1F2937)),
                                ),
                                const SizedBox(height: 10),
                                _SummaryRow(title: 'قيمة الطلب', value: _money(subtotal)),
                                if (isDelivery) ...[const SizedBox(height: 8), _SummaryRow(title: 'رسوم التوصيل', value: _money(deliveryFee))],
                                if (discount > 0) ...[
                                  const SizedBox(height: 8),
                                  _SummaryRow(title: 'الخصم', value: '- ${_money(discount)}', valueColor: const Color(0xff10B981)),
                                ],
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Divider(height: 1, color: Color(0xffE5E7EB)),
                                ),
                                _SummaryRow(
                                  title: 'الإجمالي',
                                  value: _money(total),
                                  titleStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xff1F2937)),
                                  valueStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xff1E2A78)),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(color: const Color(0xffE8F0FF), borderRadius: BorderRadius.circular(10)),
                                  child: Row(
                                    spacing: 8,
                                    children: [
                                      Icon(Icons.access_time_filled, size: 18, color: const Color(0xff1E40AF)),
                                      AppText.labelMedium(
                                        isDelivery ? 'الوقت المتوقع: 30 - 40 دقيقة' : 'الوقت المتوقع: 10 - 15 دقيقة',
                                        color: const Color(0xff1E40AF),
                                        textAlign: TextAlign.start,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isPlacingOrder
                            ? null
                            : () {
                                if (isDelivery && int.tryParse(state.selectedAddress?.id ?? '') == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى اختيار عنوان توصيل صالح')));
                                  return;
                                }
                                context.read<OrdersBloc>().add(isStoreFlow ? PlaceStoreOrderEvent() : PlaceRestaurantOrderEvent());
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff1E2A78),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: isPlacingOrder
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2.2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                              )
                            : AppText.bodyLarge('تاكيد الطلب', color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FulfillmentCard extends StatelessWidget {
  const _FulfillmentCard({required this.title, required this.subtitle, required this.icon, required this.selected, required this.onTap});

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xffFFF7ED) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? const Color(0xffF97316) : const Color(0xffE5E7EB), width: selected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(color: selected ? const Color(0xffFED7AA) : const Color(0xffF3F4F6), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: selected ? const Color(0xffB45309) : const Color(0xff9CA3AF)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.bodyLarge(title, color: selected ? const Color(0xffB45309) : const Color(0xff374151), fontWeight: FontWeight.bold),
                  AppText.labelLarge(subtitle, color: selected ? const Color(0xffC2410C) : const Color(0xff6B7280)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(selected ? Icons.check_circle : Icons.radio_button_off, color: selected ? const Color(0xffF97316) : const Color(0xffD1D5DB)),
          ],
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.title, required this.line1, required this.line2, this.topAction, this.onTopAction});

  final String title;
  final String line1;
  final String line2;
  final String? topAction;
  final VoidCallback? onTopAction;

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
          Row(
            children: [
              const Icon(Icons.location_pin, color: Color(0xff6D28D9), size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: AppText.bodyMedium(title, color: const Color(0xff1E2A78), fontWeight: FontWeight.bold, textAlign: TextAlign.start),
              ),
              if (topAction != null)
                TextButton(
                  onPressed: onTopAction,
                  child: AppText.labelMedium(topAction!, color: const Color(0xff8B5CF6), fontWeight: FontWeight.bold),
                ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xffF9FAFB), borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.labelLarge(line1, color: const Color(0xff111827)),
                if (line2.isNotEmpty) AppText.labelMedium(line2, color: const Color(0xff6B7280)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.title, required this.value, this.valueColor, this.titleStyle, this.valueStyle});

  final String title;
  final String value;
  final Color? valueColor;
  final TextStyle? titleStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: titleStyle ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xff6B7280)),
          ),
        ),
        Text(
          value,
          style: valueStyle ?? TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: valueColor ?? const Color(0xff111827)),
        ),
      ],
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
  final String scheduledLabel;
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
          AppText.bodyMedium('وقت الاستلام', color: const Color(0xff1F2937), fontWeight: FontWeight.bold),
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
                        style: TextStyle(color: isScheduled ? Colors.white : const Color(0xff111827), fontWeight: FontWeight.w700),
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
                        style: TextStyle(color: !isScheduled ? Colors.white : const Color(0xff111827), fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isScheduled) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(onPressed: onPickSchedule, icon: const Icon(Icons.calendar_month_rounded, size: 18), label: Text(scheduledLabel)),
          ],
        ],
      ),
    );
  }
}
