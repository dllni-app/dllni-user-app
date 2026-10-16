import 'package:flutter/material.dart';

/// Shared final confirmation for cleaning, occasions and hourly help.
/// Only invoked after the server quote is available.
Future<bool> showClBookingConfirmationSheet({
  required BuildContext context,
  required String title,
  required double total,
  required String currency,
  required IconData icon,
  String priceLabel = 'الإجمالي',
  String paymentNote = 'الدفع نقداً عند إتمام الخدمة.',
  String? acknowledgement,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: const Color(0xFFF6F7F9),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _ClBookingConfirmationContent(
      title: title,
      total: total,
      currency: currency,
      icon: icon,
      priceLabel: priceLabel,
      paymentNote: paymentNote,
      acknowledgement: acknowledgement,
    ),
  );
  return result == true;
}

class _ClBookingConfirmationContent extends StatefulWidget {
  const _ClBookingConfirmationContent({
    required this.title,
    required this.total,
    required this.currency,
    required this.icon,
    required this.priceLabel,
    required this.paymentNote,
    this.acknowledgement,
  });

  final String title;
  final double total;
  final String currency;
  final IconData icon;
  final String priceLabel;
  final String paymentNote;
  final String? acknowledgement;

  @override
  State<_ClBookingConfirmationContent> createState() =>
      _ClBookingConfirmationContentState();
}

class _ClBookingConfirmationContentState
    extends State<_ClBookingConfirmationContent> {
  bool _acknowledged = false;

  @override
  Widget build(BuildContext context) {
    final needsConsent = widget.acknowledgement?.trim().isNotEmpty == true;
    final formattedTotal = widget.total.toStringAsFixed(
      widget.total.truncateToDouble() == widget.total ? 0 : 2,
    );
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(widget.icon, size: 38, color: const Color(0xFF172554)),
            const SizedBox(height: 12),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF172554),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${widget.priceLabel}: $formattedTotal ${widget.currency}',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF172554),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              widget.paymentNote,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF52637C)),
            ),
            if (needsConsent) ...[
              const SizedBox(height: 14),
              Material(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFD9E2EF)),
                ),
                clipBehavior: Clip.antiAlias,
                child: CheckboxListTile(
                  key: const Key('booking_property_consent'),
                  value: _acknowledged,
                  onChanged: (value) =>
                      setState(() => _acknowledged = value ?? false),
                  title: const Text(
                    'أوافق على إقرار حماية الممتلكات',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    widget.acknowledgement!,
                    style: const TextStyle(fontSize: 12, height: 1.5),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: const Color(0xFF172554),
                ),
              ),
            ],
            const SizedBox(height: 18),
            FilledButton(
              key: const Key('confirm_send_booking'),
              onPressed: needsConsent && !_acknowledged
                  ? null
                  : () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF172554),
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: const Text('تأكيد وإرسال الطلب'),
            ),
            TextButton(
              key: const Key('review_booking_details'),
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'مراجعة التفاصيل',
                style: TextStyle(color: Color(0xFF172554)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
