import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../manager/bloc/orders_bloc.dart';

class CleaningCancelReasonDialog extends StatefulWidget {
  const CleaningCancelReasonDialog({super.key, required this.orderId, required this.bloc});

  final int orderId;
  final OrdersBloc bloc;

  @override
  State<CleaningCancelReasonDialog> createState() => _CleaningCancelReasonDialogState();
}

class _CleaningCancelReasonDialogState extends State<CleaningCancelReasonDialog> {
  final TextEditingController _reasonController = TextEditingController();
  String? _reasonValidationError;
  bool _hasSubmitted = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final reason = _reasonController.text.trim();
    _hasSubmitted = true;
    if (reason.length < 3) {
      setState(() {
        _reasonValidationError = 'يرجى إدخال سبب إلغاء صالح (3 أحرف على الأقل)';
      });
      return;
    }
    setState(() => _reasonValidationError = null);
    widget.bloc.add(CancelCleaningOrderEvent(orderId: widget.orderId, reason: reason));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: BlocConsumer<OrdersBloc, OrdersState>(
        bloc: widget.bloc,
        listenWhen: (previous, current) => previous.cancelCleaningStatus != current.cancelCleaningStatus,
        listener: (context, state) {
          if (state.cancelCleaningStatus == BlocStatus.success) {
            Navigator.of(context).pop(true);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إلغاء الطلب بنجاح')));
          }
        },
        builder: (context, state) {
          final isLoading = state.cancelCleaningStatus == BlocStatus.loading;
          final blocError = (_hasSubmitted && state.cancelCleaningStatus == BlocStatus.failed) ? state.cancelCleaningErrorMessage : null;
          return Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppText.bodyLarge(
                  'هل أنت متأكد من رغبتك في إلغاء الحجز؟',
                  textAlign: TextAlign.center,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff111827),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsetsDirectional.fromSTEB(10, 8, 10, 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF87171), style: BorderStyle.solid),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info, color: Color(0xffDC2626), size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: AppText.bodySmall(
                          'علمًا أنه سيتم إلغاء الحجز بعد إدخال سبب الإلغاء.',
                          color: Color(0xffB91C1C),
                          textAlign: TextAlign.start,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _reasonController,
                  minLines: 3,
                  maxLines: 4,
                  enabled: !isLoading,
                  style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: 'اكتب سبب الإلغاء',
                    errorText: _reasonValidationError,
                    filled: true,
                    hintStyle: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                    fillColor: const Color(0xffF9FAFB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xffD1D5DB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xffD1D5DB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xff9CA3AF)),
                    ),
                  ),
                ),
                if (blocError != null && blocError.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  AppText.labelMedium(blocError, color: const Color(0xffB91C1C), textAlign: TextAlign.start),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () => Navigator.of(context).pop(false),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xffA3A9C6),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: AppText.bodyLarge('تراجع', color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () => _submit(context),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xffE51C28),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: isLoading
                              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.3, color: Colors.white))
                              : AppText.bodyLarge('إلغاء الطلب', color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
