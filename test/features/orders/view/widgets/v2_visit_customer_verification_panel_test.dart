import 'package:common_package/helpers/dio_network.dart';
import 'package:dio/dio.dart';
import 'package:dllni_user_app/features/orders/data/source/v2_visit_customer_verification_api.dart';
import 'package:dllni_user_app/features/orders/view/widgets/v2_visit_customer_verification_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockCustomerCodeApi implements V2VisitCustomerVerificationApi {
  int bookingId = 0;
  int visit = 0;
  bool noCode = false;

  @override
  DioNetwork get network => throw UnimplementedError();

  @override
  Future<Map<String, dynamic>> code(int bookingId, int sequence) async {
    this.bookingId = bookingId;
    visit = sequence;
    if (noCode) {
      final options = RequestOptions(path: '/customer-v2');
      throw DioException(
        requestOptions: options,
        response: Response<dynamic>(requestOptions: options, statusCode: 404),
        type: DioExceptionType.badResponse,
      );
    }
    return {
      'code': '123456',
      'expiresAt': DateTime.now()
          .add(const Duration(minutes: 7))
          .toIso8601String(),
      'purpose': 'v2_visit_supervisor_start_verification',
    };
  }
}

void main() {
  testWidgets(
    'shows customer-only six digit code on demand, not automatically',
    (tester) async {
      final api = _MockCustomerCodeApi();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: V2VisitCustomerVerificationPanel(
                bookingId: 84,
                visitSequence: 2,
                api: api,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('123456'), findsNothing);
      await tester.tap(find.byKey(const Key('v2_customer_code_2')));
      await tester.pumpAndSettle();
      expect(api.bookingId, 84);
      expect(api.visit, 2);
      expect(find.text('123456'), findsOneWidget);
      expect(
        find.textContaining('للمشرف الموجود في موقع العمل'),
        findsOneWidget,
      );
      await tester.tap(find.text('إغلاق'));
      await tester.pumpAndSettle();
      expect(find.text('123456'), findsNothing);
    },
  );

  testWidgets('missing challenge informs customer without a blocking modal', (
    tester,
  ) async {
    final api = _MockCustomerCodeApi()..noCode = true;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: V2VisitCustomerVerificationPanel(
              bookingId: 84,
              visitSequence: 1,
              api: api,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('v2_customer_code_1')));
    await tester.pumpAndSettle();
    expect(find.textContaining('لم يصدر المشرف رمزاً صالحاً'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });
}
