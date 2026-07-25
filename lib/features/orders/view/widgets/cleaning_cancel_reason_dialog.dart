import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/cleaning_cancellation_fee_model.dart';
import '../../domain/usecases/fetch_cleaning_cancellation_fee_use_case.dart';
import '../manager/bloc/orders_bloc.dart';

class CleaningCancelReasonDialog extends StatefulWidget {
  const CleaningCancelReasonDialog({
    super.key,
    required this.orderId,
    required this.bloc,
  });

  final int orderId;
  final OrdersBloc bloc;

  @override
  State<CleaningCancelReasonDialog> createState() =>
      _CleaningCancelReasonDialogState();
}

class _CleaningCancelReasonDialogState extends State<CleaningCancelReasonDialog> {
  final TextEditingController _reasonController = TextEditingController();
  String? _reasonValidationError;
  bool _hasSubmitted = false;
  bool _feeLoading = true;
  String? _feeError;
  CleaningCancellationFeeModel? _fee;

  @override
  void initState() {
    super.initState();
    _loadCancellationFee();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadCancellationFee() async {
    setState(() {
      _feeLoading = true;
      _feeError = null;
    });

    final response = await getIt<FetchCleaningCancellationFeeUseCase>()(
      NoParams(),
    );

    if (!mounted) return;

    response.fold(
      (failure) {
        setState(() {
          _feeLoading = false;
          _feeError = 'تعذر تحميل غرامة الإلغاء. حاول مرة أخرى.';
        });
      },
      (fee) {
        setState(() {
          _feeLoading = false;
          _fee = fee;
          _feeError = null;
        });
      },
    );
  }

  String? _feeMessage() {
    final fee = _fee;
    if (fee == null) return null;

    if (fee.amount <= 0) {
      return 'علماً أنه يمكن إلغاء الحجز دون رسوم إلغاء حالياً.';
    }

    final amountText = fee.amount == fee.amount.roundToDouble()
        ? fee.amount.toStringAsFixed(0)
        : fee.amount.toStringAsFixed(2);

    return 'علماً أنه عند إلغاء الحجز سيتم احتساب غرامة بمبلغ $amountText ${fee.currency}.';
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
    widget.bloc.add(
      CancelCleaningOrderEvent(orderId: widget.orderId, reason: reason),
    );
  }

  @override
  Widget build(BuildContext context) {
    final feeMessage = _feeMessage();

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: BlocConsumer<OrdersBloc, OrdersState>(
        bloc: widget.bloc,
        listenWhen: (previous, current) =>
            previous.cancelCleaningStatus != current.cancelCleaningStatus,
        listener: (context, state) {
          if (state.cancelCleaningStatus == BlocStatus.success) {
            Navigator.of(context).pop(true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم إلغاء الطلب بنجاح')),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state.cancelCleaningStatus == BlocStatus.loading;
          final blocError =
              (_hasSubmitted && state.cancelCleaningStatus == BlocStatus.failed)
              ? state.cancelCleaningErrorMessage
              : null;
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
                TextField(
                  controller: _reasonController,
                  minLines: 3,
                  maxLines: 4,
                  enabled: !isLoading,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: 'اكتب سبب الإلغاء',
                    errorText: _reasonValidationError,
                    filled: true,
                    hintStyle: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
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
                const SizedBox(height: 10),
                if (_feeLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.3),
                      ),
                    ),
                  )
                else if (_feeError != null) ...[
                  Container(
                    padding: const EdgeInsetsDirectional.fromSTEB(10, 8, 10, 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFF59E0B)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppText.bodySmall(
                            _feeError!,
                            color: const Color(0xFF92400E),
                            textAlign: TextAlign.start,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton(
                          onPressed: isLoading ? null : _loadCancellationFee,
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                ] else if (feeMessage != null) ...[
                  Container(
                    padding: const EdgeInsetsDirectional.fromSTEB(10, 8, 10, 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFF87171),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info,
                          color: Color(0xffDC2626),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: AppText.bodySmall(
                            feeMessage,
                            color: Color(0xffB91C1C),
                            textAlign: TextAlign.start,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (blocError != null && blocError.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  AppText.labelMedium(
                    blocError,
                    color: const Color(0xffB91C1C),
                    textAlign: TextAlign.start,
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () => Navigator.of(context).pop(false),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xffA3A9C6),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: AppText.bodyLarge(
                            'تراجع',
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.3,
                                    color: Colors.white,
                                  ),
                                )
                              : AppText.bodyLarge(
                                  'إلغاء الطلب',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
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
