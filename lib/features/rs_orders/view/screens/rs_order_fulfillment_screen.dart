import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/features/rs_profile/domain/models/rs_address_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/rs_order_address.dart';
import '../manager/bloc/rs_orders_bloc.dart';

@AutoRoutePage(path: '/rsorderfulfillment')
class RsOrderFulfillmentScreen extends StatelessWidget {
  const RsOrderFulfillmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<RsOrdersBloc, RsOrdersState>(
      listenWhen: (p, c) => p.message != c.message && c.message != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message!)));
      },
      child: Scaffold(
        backgroundColor: const Color(0xffF3F4F6),
        body: SafeArea(
          child: BlocBuilder<RsOrdersBloc, RsOrdersState>(
            builder: (context, state) {
              return SingleChildScrollView(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _PageHeader(title: 'الطلبية الحالية'),
                  const SizedBox(height: 16),
                  AppText.bodyLarge(
                    'اختر الطريقة المناسبة لاستلام طلبك',
                    color: const Color(0xff4F46E5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  _FulfillmentOptionCard(
                    title: 'توصيل إلى العنوان',
                    subtitle: 'سيتم توصيل الطلب إلى موقعك',
                    icon: Icons.delivery_dining,
                    selected:
                        state.fulfillmentType ==
                        RsOrderFulfillmentType.delivery,
                    onTap: () => context.read<RsOrdersBloc>().add(
                      RsOrderFulfillmentChanged(
                        RsOrderFulfillmentType.delivery,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FulfillmentOptionCard(
                    title: 'استلام من المطعم',
                    subtitle: 'يمكنك استلام الطلب بنفسك',
                    icon: Icons.store_mall_directory,
                    selected:
                        state.fulfillmentType == RsOrderFulfillmentType.pickup,
                    onTap: () => context.read<RsOrdersBloc>().add(
                      RsOrderFulfillmentChanged(RsOrderFulfillmentType.pickup),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _LocationCard(state: state),
                  const SizedBox(height: 12),
                  _FinalSummaryCard(state: state),
                ],
              ),
              );
            },
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 16),
            child: SizedBox(
              height: 56,
              child: BlocBuilder<RsOrdersBloc, RsOrdersState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: state.checkoutStatus == BlocStatus.loading
                        ? null
                        : () => context.read<RsOrdersBloc>().add(RsOrderCheckoutSubmitted()),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: context.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: state.checkoutStatus == BlocStatus.loading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                        : AppText.labelLarge(
                            'المراجعة النهائية',
                            color: context.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                  );
                },
              ),
            ),
          ),
        ),
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
        border: Border(
          bottom: BorderSide(color: context.primaryContainer, width: 2),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.arrow_forward, color: context.primary),
          ),
          Expanded(
            child: AppText.headlineMedium(
              title,
              color: context.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _FulfillmentOptionCard extends StatelessWidget {
  const _FulfillmentOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

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
        padding: const EdgeInsetsDirectional.all(12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xffFFF7ED) : context.onPrimary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? context.primaryContainer
                : const Color(0xffD1D5DB),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected
                  ? context.primaryContainer
                  : const Color(0xffD1D5DB),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppText.headlineSmall(
                    title,
                    color: selected
                        ? const Color(0xffB45309)
                        : const Color(0xff374151),
                    fontWeight: FontWeight.w700,
                  ),
                  const SizedBox(height: 4),
                  AppText.bodyMedium(subtitle, color: const Color(0xff6B7280)),
                ],
              ),
            ),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xffFED7AA)
                    : const Color(0xffE5E7EB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: selected
                    ? const Color(0xffB45309)
                    : const Color(0xff6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.state});

  final RsOrdersState state;

  @override
  Widget build(BuildContext context) {
    final isDelivery = state.fulfillmentType == RsOrderFulfillmentType.delivery;
    final restaurantName = state.selectedOrder?.restaurant?.name ?? '';
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
          Row(
            children: [
              Expanded(
                child: AppText.headlineSmall(
                  isDelivery ? 'موقع التوصيل' : 'موقع المطعم',
                  color: context.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (isDelivery)
                InkWell(
                  onTap: () => _pickAddress(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffEDE9FE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: AppText.labelLarge(
                      'تغيير',
                      color: const Color(0xff6D28D9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsetsDirectional.all(12),
            decoration: BoxDecoration(
              color: const Color(0xffF9FAFB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppText.bodyLarge(
                  isDelivery
                      ? (state.deliveryAddress.label.isEmpty ? '—' : state.deliveryAddress.label)
                      : (restaurantName.isEmpty ? '—' : restaurantName),
                  color: const Color(0xff1F2937),
                  fontWeight: FontWeight.w600,
                ),
                if (isDelivery && state.deliveryAddress.cityLine.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  AppText.bodyMedium(
                    state.deliveryAddress.cityLine,
                    color: const Color(0xff6B7280),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAddress(BuildContext context) async {
    final result = await context.pushRoute<RsAddressListItem>(
      '/rsmyaddresses',
      arguments: true,
    );
    if (result == null || !context.mounted) {
      return;
    }

    context.read<RsOrdersBloc>().add(
      RsOrderAddressChanged(
        RsOrderAddress(
          id: result.id,
          label: result.line1.split(' - ').take(2).join('، '),
          cityLine: result.line1,
          streetLine: result.landmark ?? '',
        ),
      ),
    );
  }
}

class _FinalSummaryCard extends StatelessWidget {
  const _FinalSummaryCard({required this.state});

  final RsOrdersState state;

  @override
  Widget build(BuildContext context) {
    final subtotal = state.selectedOrder?.subtotal;
    final total = state.selectedOrder?.totalAmount;
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
          AppText.headlineSmall(
            'ملخص الطلب',
            color: context.primary,
            fontWeight: FontWeight.w700,
          ),
          const SizedBox(height: 10),
          _SummaryLine(
            label: 'قيمة الطلب',
            value: subtotal == null ? '—' : '$subtotal ل.س',
            ),
          _SummaryLine(
            label: 'الإجمالي',
            value: total == null ? '—' : '$total ل.س',
            valueColor: context.primary,
            valueWeight: FontWeight.w800,
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.label,
    required this.value,
    this.valueColor = const Color(0xff1F2937),
    this.valueWeight = FontWeight.w600,
  });

  final String label;
  final String value;
  final Color valueColor;
  final FontWeight valueWeight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: 3),
      child: Row(
        children: [
          AppText.bodyLarge(label, color: const Color(0xff4B5563)),
          const Spacer(),
          AppText.bodyLarge(value, color: valueColor, fontWeight: valueWeight),
        ],
      ),
    );
  }
}
