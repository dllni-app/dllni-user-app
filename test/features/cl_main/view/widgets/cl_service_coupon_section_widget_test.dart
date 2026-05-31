import 'package:dllni_user_app/features/cl_main/view/widgets/cl_service_coupon_section_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _CouponHarness extends StatefulWidget {
  const _CouponHarness();

  @override
  State<_CouponHarness> createState() => _CouponHarnessState();
}

class _CouponHarnessState extends State<_CouponHarness> {
  final TextEditingController _controller = TextEditingController();
  ClCouponUiStatus _status = ClCouponUiStatus.idle;
  String? _message;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onApply(String code) async {
    setState(() {
      _status = ClCouponUiStatus.loading;
      _message = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    if (code.trim().toLowerCase() == 'invalid') {
      setState(() {
        _status = ClCouponUiStatus.failed;
        _message = 'invalid coupon';
      });
      return;
    }

    setState(() {
      _status = ClCouponUiStatus.success;
      _message = 'discount 20%';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ClServiceCouponSectionWidget(
            couponController: _controller,
            status: _status,
            message: _message,
            onApply: _onApply,
          ),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('applies coupon and shows success then failure feedback', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const _CouponHarness());

    await tester.enterText(find.byType(TextField), 'EID20');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.textContaining('20%'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'invalid');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });
}
