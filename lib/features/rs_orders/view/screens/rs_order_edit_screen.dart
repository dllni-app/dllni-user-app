import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/rs_order_item.dart';
import '../manager/bloc/rs_orders_bloc.dart';
import 'rs_order_fulfillment_screen.dart';

@AutoRoutePage(path: '/rsorderedit')
class RsOrderEditScreen extends StatefulWidget {
  const RsOrderEditScreen({super.key});

  @override
  State<RsOrderEditScreen> createState() => _RsOrderEditScreenState();
}

class _RsOrderEditScreenState extends State<RsOrderEditScreen> {
  late final TextEditingController _couponController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final state = context.read<RsOrdersBloc>().state;
    _couponController = TextEditingController(text: state.appliedCouponCode ?? '');
    _notesController = TextEditingController(text: state.notes);
  }

  @override
  void dispose() {
    _couponController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF3F4F6),
      body: SafeArea(
        child: BlocBuilder<RsOrdersBloc, RsOrdersState>(
          builder: (context, state) {
            return Column(
              children: [
                const _PageHeader(title: 'الطلبية الحالية'),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!state.hasItems)
                          Container(
                            padding: const EdgeInsetsDirectional.all(16),
                            margin: const EdgeInsetsDirectional.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: context.onPrimary,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xffE5E7EB)),
                            ),
                            child: AppText.bodyLarge('الطلب الحالي فارغ', color: const Color(0xff6B7280), textAlign: TextAlign.center),
                          ),
                        ...state.items.map((item) => _OrderItemCard(item: item)),
                        const SizedBox(height: 10),
                        _CouponSection(controller: _couponController),
                        const SizedBox(height: 18),
                        _NotesSection(controller: _notesController),
                        const SizedBox(height: 18),
                        _OrderSummaryCard(state: state),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: BlocBuilder<RsOrdersBloc, RsOrdersState>(
        builder: (context, state) {
          return SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 16),
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: state.hasItems
                      ? () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<RsOrdersBloc>(),
                                child: const RsOrderFulfillmentScreen(),
                              ),
                            ),
                          )
                      : null,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: context.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: AppText.labelLarge('تحديد طريقة استلام الطلب', color: context.onPrimary, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.onPrimary,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        border: Border(bottom: BorderSide(color: context.primaryContainer, width: 2)),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              context.pop();
            },
            child: Icon(Icons.arrow_back_ios_new, color: context.primary),
          ),
          SizedBox(width: 9),
          Expanded(
            child: AppText.headlineMedium(title, color: context.primary, fontWeight: FontWeight.bold, textAlign: TextAlign.start),
          ),
        ],
      ),
    );
  }
}

class _OrderItemCard extends StatelessWidget {
  const _OrderItemCard({required this.item});

  final RsOrderItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.only(bottom: 12),
      padding: const EdgeInsetsDirectional.all(12),
      decoration: BoxDecoration(
        color: context.onPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 84,
                  height: 84,
                  color: const Color(0xFFF5F5F5),
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_outlined, color: Color(0xFF9CA3AF)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.bodyLarge(item.name, color: context.primary, fontWeight: FontWeight.w700),
                    const SizedBox(height: 6),
                    AppText.labelLarge(item.restaurantName, color: const Color(0xff374151), scrollText: true, textAlign: TextAlign.start),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _QuantityStepper(item: item),
              const Spacer(),
              AppText.headlineSmall('${item.totalPrice} ل.س', color: context.primary, fontWeight: FontWeight.w800),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () => context.read<RsOrdersBloc>().add(RsOrderItemRemoved(item.id)),
                child: Row(
                  spacing: 8,
                  children: [
                    Icon(Icons.delete_outline_outlined, color: Color(0xffEF4444), size: 20),
                    AppText.labelLarge('حذف', color: Color(0xffEF4444), fontWeight: FontWeight.w500),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({required this.item});

  final RsOrderItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: item.quantity > 1
                ? () {
                    context.read<RsOrdersBloc>().add(RsOrderItemQuantityChanged(itemId: item.id, quantity: item.quantity - 1));
                  }
                : null,
            icon: Icon(Icons.remove, color: context.primary, size: 18),
          ),
          AppText.titleMedium('${item.quantity}', color: context.primary, fontWeight: FontWeight.w700),
          IconButton(
            onPressed: () {
              context.read<RsOrdersBloc>().add(RsOrderItemQuantityChanged(itemId: item.id, quantity: item.quantity + 1));
            },
            icon: Icon(Icons.add, color: context.primary, size: 18),
          ),
        ],
      ),
    );
  }
}

class _CouponSection extends StatelessWidget {
  const _CouponSection({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.all(14),
      decoration: BoxDecoration(
        color: context.onPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.headlineSmall('هل لديك كود خصم؟', color: const Color(0xff1F2937), fontWeight: FontWeight.w700),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'أدخل كود الخصم هنا',
                    filled: true,
                    fillColor: const Color(0xffF9FAFB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xffE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xffE5E7EB)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('غير متاح'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(color: const Color(0xffFEF3C7), borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: const [
                Icon(Icons.info_outline, size: 18, color: Color(0xff92400E)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'تطبيق كوبون الخصم غير متاح حالياً',
                    style: TextStyle(color: Color(0xff92400E)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          BlocBuilder<RsOrdersBloc, RsOrdersState>(
            builder: (context, state) {
              if (state.message == null || state.message!.trim().isEmpty) {
                return const SizedBox.shrink();
              }
              final backgroundColor = state.isMessageSuccess ? const Color(0xffDCFCE7) : const Color(0xffFEE2E2);
              final textColor = state.isMessageSuccess ? const Color(0xff15803D) : const Color(0xffB91C1C);
              return Container(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 9),
                decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Icon(state.isMessageSuccess ? Icons.check_circle : Icons.error, size: 18, color: textColor),
                    const SizedBox(width: 8),
                    Expanded(child: AppText.bodySmall(state.message!, color: textColor)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NotesSection extends StatelessWidget {
  const _NotesSection({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.all(14),
      decoration: BoxDecoration(
        color: context.onPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText.headlineSmall('ملاحظات الطلب', color: const Color(0xff1F2937), fontWeight: FontWeight.w700),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            onChanged: (value) => context.read<RsOrdersBloc>().add(RsOrderNotesChanged(value)),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'ملاحظات إضافية للمطعم (اختياري)...',
              filled: true,
              fillColor: const Color(0xffF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xffE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xffE5E7EB)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.state});

  final RsOrdersState state;

  @override
  Widget build(BuildContext context) {
    final subtotal = state.selectedOrder?.subtotal;
    final totalAmount = state.selectedOrder?.totalAmount;
    return Container(
      padding: const EdgeInsetsDirectional.all(14),
      decoration: BoxDecoration(
        color: context.onPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText.headlineSmall('ملخص الطلب', color: const Color(0xff1F2937), fontWeight: FontWeight.w700),
          const SizedBox(height: 10),
          _SummaryRow(title: 'مجموع المنتجات', value: subtotal == null ? '—' : '$subtotal ل.س'),
          _SummaryRow(title: 'الخصم (كوبون)', value: '—', valueColor: const Color(0xff16A34A)),
          const Divider(height: 16, color: Color(0xffE5E7EB)),
          _SummaryRow(
            title: 'الإجمالي النهائي',
            value: totalAmount == null ? '—' : '$totalAmount ل.س',
            titleColor: context.primary,
            valueColor: context.primary,
            valueWeight: FontWeight.w800,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.title,
    required this.value,
    this.titleColor = const Color(0xff374151),
    this.valueColor = const Color(0xff111827),
    this.valueWeight = FontWeight.w600,
  });

  final String title;
  final String value;
  final Color titleColor;
  final Color valueColor;
  final FontWeight valueWeight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: 3),
      child: Row(
        children: [
          AppText.bodyLarge(title, color: titleColor),
          const Spacer(),
          AppText.bodyLarge(value, color: valueColor, fontWeight: valueWeight),
        ],
      ),
    );
  }
}
