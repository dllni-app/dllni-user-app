import 'package:common_package/helpers/dio_network.dart';
import 'package:dio/dio.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';

import '../../data/source/v2_visit_customer_verification_api.dart';
import 'v7_order_detail_components.dart';

/// A deliberate, customer-initiated code reveal, never a global blocking modal.
/// The supervisor sees only a verification status, never the customer code.
class V2VisitCustomerVerificationPanel extends StatefulWidget {
  const V2VisitCustomerVerificationPanel({
    super.key,
    required this.bookingId,
    required this.visitSequence,
    this.api,
  });

  final int bookingId;
  final int visitSequence;
  final V2VisitCustomerVerificationApi? api;

  @override
  State<V2VisitCustomerVerificationPanel> createState() =>
      _V2VisitCustomerVerificationPanelState();
}

class _V2VisitCustomerVerificationPanelState
    extends State<V2VisitCustomerVerificationPanel> {
  bool _busy = false;
  String? _error;

  Future<void> _reveal() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final api =
          widget.api ?? V2VisitCustomerVerificationApi(getIt<DioNetwork>());
      final response = await api.code(widget.bookingId, widget.visitSequence);
      final code = response['code']?.toString() ?? '';
      final expires = DateTime.tryParse(
        response['expiresAt']?.toString() ?? '',
      );
      if (!RegExp(r'^[0-9]{6}$').hasMatch(code) || expires == null) {
        throw const FormatException('Invalid verification challenge');
      }
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text('رمز بدء الزيارة ${widget.visitSequence}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('أعطِ هذا الرمز للمشرف الموجود في موقع العمل فقط.'),
                const SizedBox(height: 14),
                SelectableText(
                  code,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 10),
                const Text('الرمز صالح لمدة محدودة ولمرة واحدة.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('إغلاق'),
              ),
            ],
          ),
        ),
      );
    } on DioException catch (error) {
      if (mounted) {
        setState(
          () => _error = switch (error.response?.statusCode) {
            404 => 'لم يصدر المشرف رمزاً صالحاً لهذه الزيارة بعد.',
            401 => 'انتهت جلستك. سجّل الدخول من جديد.',
            _ => 'تعذر جلب الرمز. حدّث الطلب وحاول مرة أخرى.',
          },
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'تعذر قراءة رمز الزيارة. حاول مجدداً.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => V7OrderPanel(
    title: 'رمز بدء الزيارة ${widget.visitSequence}',
    subtitle: 'رمز خاص بالمشرف لهذه الزيارة فقط، وليس رمز العامل الفردي.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_error != null) ...[
          Text(_error!, style: const TextStyle(color: Color(0xFFB42318))),
          const SizedBox(height: 8),
        ],
        FilledButton.icon(
          key: Key('v2_customer_code_${widget.visitSequence}'),
          onPressed: _busy ? null : _reveal,
          icon: const Icon(Icons.lock_outline),
          label: Text(
            _busy ? 'جارٍ التحقق من توفر الرمز...' : 'عرض رمز المشرف',
          ),
        ),
      ],
    ),
  );
}
