import 'package:common_package/helpers/dio_network.dart';
import 'package:dio/dio.dart';
import 'package:dllni_user_app/core/realtime/cleaning_global_verification_gate_coordinator.dart';
import 'package:dllni_user_app/features/orders/data/models/cleaning_orders_api_models.dart';
import 'package:dllni_user_app/features/orders/data/source/supervised_team_customer_api.dart';
import 'package:dllni_user_app/features/orders/view/screens/supervised_team_customer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _prefix = '/api/v1/supervised-team/customer/bookings/42';

void main() {
  test(
    'supervised bookings bypass legacy customer verification and completion prompts',
    () {
      final orders = [
        for (final status in [
          'awaiting_start_verification',
          'awaiting_customer_completion',
        ])
          CleaningOrderModel.fromJson({
            'id': 42,
            'bookingKind': 'supervised_team',
            'status': status,
          }),
      ];
      expect(
        CleaningGlobalVerificationGateCoordinator.findAwaitingVerificationOrderIds(
          orders,
        ),
        isEmpty,
      );
      expect(
        CleaningGlobalVerificationGateCoordinator.findAwaitingCompletionOrderIds(
          orders,
        ),
        isEmpty,
      );
      final details = CleaningOrderDetailModel.fromJson({
        'bookingKind': 'supervised_team',
      });
      expect(details.toCleaningOrderModel().isSupervisedTeam, isTrue);
    },
  );

  testWidgets(
    'loads private code only on demand and sends extension decisions to the customer endpoint',
    (tester) async {
      final requests = <RequestOptions>[];
      var decided = false;
      final api = SupervisedTeamCustomerApi(
        DioNetwork(
          baseUrl: 'https://example.test',
          interceptors: [
            InterceptorsWrapper(
              onRequest: (options, handler) {
                requests.add(options);
                if (options.path.endsWith('/decision')) {
                  decided = true;
                  handler.resolve(
                    Response(
                      requestOptions: options,
                      statusCode: 200,
                      data: {
                        'data': {'status': 'approved'},
                      },
                    ),
                  );
                } else if (options.path.endsWith('/verification-code')) {
                  handler.resolve(
                    Response(
                      requestOptions: options,
                      statusCode: 200,
                      data: {
                        'data': {
                          'code': '123456',
                          'expiresAt': DateTime.now()
                              .add(const Duration(minutes: 5))
                              .toIso8601String(),
                        },
                      },
                    ),
                  );
                } else {
                  handler.resolve(
                    Response(
                      requestOptions: options,
                      statusCode: 200,
                      data: {
                        'data': {
                          'booking': {
                            'bookingNumber': 'TEAM-42',
                            'teamState': 'verification_pending',
                            'arrivedWorkers': 3,
                            'requiredWorkers': 3,
                          },
                          'allowedActions': decided
                              ? []
                              : ['view_verification_code', 'decide_extension'],
                          'extensions': decided
                              ? []
                              : [
                                  {
                                    'id': 7,
                                    'additionalMinutes': 30,
                                    'reason': 'وقت إضافي لإنهاء العمل',
                                    'status': 'pending',
                                  },
                                ],
                          'handover': {'status': 'not_requested'},
                        },
                      },
                    ),
                  );
                }
              },
            ),
          ],
        ),
      );
      await tester.pumpWidget(
        MaterialApp(home: SupervisedTeamCustomerScreen(orderId: 42, api: api)),
      );
      await tester.pumpAndSettle();
      expect(requests.single.path, _prefix);
      await tester.tap(find.text('عرض رمز البدء'));
      await tester.pumpAndSettle();
      expect(requests.last.path, '$_prefix/verification-code');
      expect(find.text('123456'), findsOneWidget);
      await tester.tap(find.text('إغلاق'));
      await tester.pumpAndSettle();
      expect(find.text('123456'), findsNothing);
      await tester.dragUntilVisible(
        find.text('الموافقة على التمديد'),
        find.byType(ListView).first,
        const Offset(0, -300),
      );
      await tester.tap(find.text('الموافقة على التمديد'));
      await tester.pumpAndSettle();
      final decision = requests.singleWhere(
        (request) => request.method == 'POST',
      );
      expect(decision.path, '$_prefix/extensions/7/decision');
      expect(decision.data, {'decision': 'approved'});
      expect(find.text('الموافقة على التمديد'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('shows team workers without per-worker contact buttons', (
    tester,
  ) async {
    final api = SupervisedTeamCustomerApi(
      DioNetwork(
        baseUrl: 'https://example.test',
        interceptors: [
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'data': {
                      'booking': <String, dynamic>{},
                      'allowedActions': <String>[],
                      'extensions': <Map<String, dynamic>>[],
                      'handover': <String, dynamic>{},
                    },
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
    final order = CleaningOrderDetailModel.fromJson({
      'id': 42,
      'booking_kind': 'supervised_team',
      'worker_assignments': [
        {
          'status': 'accepted',
          'worker': {'name': 'عامل الفريق', 'phone': '+963900000000'},
        },
      ],
    });

    await tester.pumpWidget(
      MaterialApp(
        home: SupervisedTeamCustomerScreen(orderId: 42, order: order, api: api),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('عامل الفريق'), findsOneWidget);
    expect(find.byTooltip('الاتصال بمقدم الخدمة'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'requires an objection reason and renders a readable RTL handover at large text',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final requests = <RequestOptions>[];
      final api = SupervisedTeamCustomerApi(
        DioNetwork(
          baseUrl: 'https://example.test',
          interceptors: [
            InterceptorsWrapper(
              onRequest: (options, handler) {
                requests.add(options);
                handler.resolve(
                  Response(
                    requestOptions: options,
                    statusCode: 200,
                    data: {
                      'data': {
                        'booking': {
                          'bookingNumber': 'TEAM-42',
                          'teamState': 'handover_pending',
                          'arrivedWorkers': 3,
                          'requiredWorkers': 3,
                        },
                        'allowedActions': ['decide_handover'],
                        'extensions': [],
                        'handover': {'status': 'pending'},
                      },
                    },
                  ),
                );
              },
            ),
          ],
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: SupervisedTeamCustomerScreen(orderId: 42, api: api),
        ),
      );
      await tester.pumpAndSettle();
      final rejectButton = find.widgetWithText(
        OutlinedButton,
        'إرسال الاعتراض',
      );
      expect(tester.widget<OutlinedButton>(rejectButton).onPressed, isNull);
      await tester.ensureVisible(find.byType(TextField));
      await tester.enterText(
        find.byType(TextField),
        'جودة الخدمة تحتاج مراجعة',
      );
      tester.testTextInput.hide();
      await tester.pumpAndSettle();
      await tester.ensureVisible(rejectButton);
      expect(tester.takeException(), isNull);
      await tester.tap(rejectButton);
      await tester.pumpAndSettle();
      final decision = requests.singleWhere(
        (request) => request.method == 'POST',
      );
      expect(decision.path, '$_prefix/handover-decision');
      expect(decision.data, {
        'decision': 'objected',
        'note': 'جودة الخدمة تحتاج مراجعة',
      });
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'keeps failed customer requests retryable without showing success',
    (tester) async {
      var calls = 0;
      final api = SupervisedTeamCustomerApi(
        DioNetwork(
          baseUrl: 'https://example.test',
          interceptors: [
            InterceptorsWrapper(
              onRequest: (options, handler) {
                calls++;
                handler.reject(
                  DioException(
                    requestOptions: options,
                    type: DioExceptionType.connectionError,
                  ),
                );
              },
            ),
          ],
        ),
      );
      await tester.pumpWidget(
        MaterialApp(home: SupervisedTeamCustomerScreen(orderId: 42, api: api)),
      );
      await tester.pumpAndSettle();
      expect(find.text('إعادة المحاولة'), findsOneWidget);
      expect(find.text('تأكيد استلام الخدمة'), findsNothing);
      await tester.tap(find.text('إعادة المحاولة'));
      await tester.pumpAndSettle();
      expect(calls, 2);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
