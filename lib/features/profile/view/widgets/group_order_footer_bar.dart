import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../orders/data/models/orders_api_models.dart';
import '../../../orders/view/screens/restaurant_order_tracking_screen.dart';
import '../manager/bloc/profile_bloc.dart';

class GroupOrderFooterBar extends StatefulWidget {
  final bool isCreator;
  final bool isLoading;
  final bool canSubmit;

  /// Creator: place whole group order. Member: send/unsend response ([SubmitGroupOrder]/[UnsubmitGroupOrder]).
  final String primaryButtonLabel;
  final VoidCallback onSubmitOrPlace;
  final VoidCallback? onCancel;

  const GroupOrderFooterBar({
    super.key,
    required this.isCreator,
    required this.isLoading,
    required this.canSubmit,
    this.primaryButtonLabel = 'التأكيد والإضافة إلى السلة',
    required this.onSubmitOrPlace,
    this.onCancel,
  });

  @override
  State<GroupOrderFooterBar> createState() => _GroupOrderFooterBarState();
}

class _GroupOrderFooterBarState extends State<GroupOrderFooterBar> {
  bool _isPlacedOrderResult(GroupOrderActionModel? result) {
    if (result == null) return false;
    final placedOrderId =
        result.placedOrderId ?? result.details?.groupOrder?.placedOrderId;
    if (placedOrderId != null && placedOrderId > 0) return true;

    final status =
        (result.status ?? result.details?.groupOrder?.status ?? '')
            .trim()
            .toLowerCase();
    return status == 'placed' ||
        status == 'ordered' ||
        status == 'completed';
  }

  int? _placedOrderId(GroupOrderActionModel? result) {
    final id = result?.placedOrderId ?? result?.details?.groupOrder?.placedOrderId;
    return id != null && id > 0 ? id : null;
  }

  void _handleGroupOrderAction(ProfileState state) {
    if (state.groupOrderActionStatus != BlocStatus.success) return;

    if (widget.isCreator && _isPlacedOrderResult(state.groupOrderActionResult)) {
      final placedOrderId = _placedOrderId(state.groupOrderActionResult);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        _showPlacedOrderSuccessSheet(placedOrderId: placedOrderId);
      });
      return;
    }

    if (!widget.isCreator) {
      final isUnsubmit = widget.primaryButtonLabel.contains('إلغاء الإرسال');
      final message = isUnsubmit
          ? 'تم إلغاء إرسال اختياراتك بنجاح'
          : 'تم إرسال اختياراتك بنجاح';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      });
    }
  }

  Future<void> _showPlacedOrderSuccessSheet({int? placedOrderId}) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.onPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 60,
                    color: Color(0xff10B981),
                  ),
                  const SizedBox(height: 14),
                  AppText.titleMedium(
                    'تم إنشاء طلبك بنجاح',
                    fontWeight: FontWeight.w800,
                  ),
                  const SizedBox(height: 8),
                  AppText.bodyMedium(
                    'تم إرسال طلبك إلى المطعم، ويمكنك متابعة حالته ومعرفة آخر التحديثات.',
                    color: const Color(0xff6B7280),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        if (placedOrderId != null) {
                          context.pushRoute(
                            '/restaurant-order-tracking',
                            arguments: RestaurantOrderTrackingArgs(
                              order: OrderResourceModel(id: placedOrderId),
                              section: 'restaurant',
                            ),
                          );
                          return;
                        }
                        context.pushRoute('/main', arguments: 1);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primary,
                        foregroundColor: context.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.receipt_long_outlined),
                      label: AppText.labelLarge(
                        'متابعة الطلب',
                        color: context.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: AppText.labelLarge(
                      'لاحقاً',
                      color: const Color(0xff6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen: (previous, current) =>
          previous.groupOrderActionStatus != current.groupOrderActionStatus,
      listener: (context, state) => _handleGroupOrderAction(state),
      child: Row(
        children: [
          Expanded(
            flex: widget.isCreator ? 2 : 1,
            child: ElevatedButton(
              onPressed: widget.isLoading || !widget.canSubmit
                  ? null
                  : widget.onSubmitOrPlace,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primary,
                foregroundColor: context.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: AppText.labelLarge(
                widget.primaryButtonLabel,
                color: context.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (widget.isCreator) ...[
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: widget.isLoading ? null : widget.onCancel,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: context.error.withAlpha(200)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: AppText.labelLarge(
                  'إلغاء',
                  color: context.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
