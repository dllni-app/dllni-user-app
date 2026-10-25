import 'dart:convert';
import 'dart:typed_data';

import 'package:common_package/helpers/dio_network.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/core/models/cleaning_gender_preference.dart';
import 'package:dllni_user_app/features/cl_main/data/repository/cl_main_repo_impl.dart';
import 'package:dllni_user_app/features/cl_main/data/source/cl_main_remote_data_source.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_booking_draft.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_recurring_session.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_progressive_room_state.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_room_size_breakdown.dart';
import 'package:dllni_user_app/features/cl_main/domain/models/cleaning_type.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/create_cleaning_order_use_case.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/estimate_cleaning_price_use_case.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/get_cleaning_services_use_case.dart';
import 'package:dllni_user_app/features/cl_main/domain/usecases/get_previous_cleaning_workers_use_case.dart';
import 'package:dllni_user_app/features/cl_main/view/data/cl_main_route_args.dart';
import 'package:dllni_user_app/features/cl_main/view/manager/bloc/cl_main_bloc.dart';
import 'package:dllni_user_app/features/cl_main/view/screens/cleaning_booking_v2_screen.dart';
import 'package:dllni_user_app/features/profile/domain/models/address_list_item.dart';

// Only the HTTP transport is replaced; production source, parsing, draft and UI run together.
class BookingTransport implements HttpClientAdapter {
  bool failCreate = false;
  bool invalidSchedule = false;
  int materialPreviewCount = 1;
  final List<Map<String, dynamic>> submissions = [];
  final List<Map<String, dynamic>> estimates = [];
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path.endsWith('/api/v1/cleaning-services')) {
      return ResponseBody.fromString(
        jsonEncode({
          'data': [
            {
              'id': 8,
              'name': 'تنظيف الكنب',
              'category': 'special_service',
              'isActive': true,
              'description': 'تنظيف الكنب والعناية بالأقمشة',
              'unitCode': 'seat',
              'supportsDirtiness': true,
            },
          ],
        }),
        200,
        headers: {
          'content-type': ['application/json'],
        },
      );
    }
    final request = Map<String, dynamic>.from(options.data as Map);
    if (options.path.endsWith('/materials-preview')) {
      return ResponseBody.fromString(
        jsonEncode({
          'contractVersion': 2,
          'materialsPreview': {
            'items': [
              for (var i = 0; i < materialPreviewCount; i++)
                {
                  'materialTypeId': 4 + i,
                  'name': i == 0 ? 'منظف الأرضيات' : 'مادة إضافية رقم ${i + 1}',
                },
            ],
            'roomWorkMinutes': {'bedroom.1': 240, 'bedroom.2': 120},
            'catalogStatus': 'ready',
          },
        }),
        200,
        headers: {
          'content-type': ['application/json'],
        },
      );
    }
    if (options.path.endsWith('/estimate-price')) {
      estimates.add(request);
      if (invalidSchedule) {
        return ResponseBody.fromString(
          jsonEncode({
            'message': 'خطأ في الموعد',
            'errors': {
              'visits.0.roomSchedules.1.numberOfWorkers': [
                'عدد العمال غير متاح لهذه الغرفة',
              ],
            },
          }),
          422,
          headers: {
            'content-type': ['application/json'],
          },
        );
      }
      final visits = (request['visits'] as List).map((rawVisit) {
        final visit = Map<String, dynamic>.from(rawVisit as Map);
        return {
          ...visit,
          'roomSchedules': [
            for (final raw in visit['roomSchedules'] as List)
              {
                ...raw as Map,
                'estimatedWorkMinutes': (raw)['roomKey'] == 'bedroom.1'
                    ? 240
                    : 120,
              },
          ],
        };
      }).toList();
      return ResponseBody.fromString(
        jsonEncode({
          'visits': visits,
          'quoteId': 'quote.one',
          'quoteSignature': 'signed',
          'quoteExpiresAt': DateTime.now()
              .add(const Duration(minutes: 15))
              .toIso8601String(),
          'pricing': {'totalPrice': 350, 'currency': 'SYP'},
          'schedulingPolicy': {'minimumWorkers': 1, 'maximumWorkers': 20},
          'materialsPreview': [
            {'materialTypeId': 4, 'name': 'منظف الأرضيات'},
          ],
          'specialServicesCatalog': [
            {
              'specialServiceId': 8,
              'name': 'تنظيف الكنب',
              'unitCode': 'seat',
              'supportsDirtiness': true,
            },
          ],
        }),
        200,
        headers: {
          'content-type': ['application/json'],
        },
      );
    }
    submissions.add(request);
    if (failCreate) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.receiveTimeout,
      );
    }
    return ResponseBody.fromString(
      jsonEncode({
        'order': {'id': 81},
        'success': true,
      }),
      201,
      headers: {
        'content-type': ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

CleaningBookingDraft sharedPeriod() {
  var draft = CleaningBookingDraft.fromRooms(const [
    CleaningProgressiveRoomUnit(
      roomType: CleaningRoomType.bedroom,
      index: 1,
      size: CleaningRoomSize.medium,
    ),
    CleaningProgressiveRoomUnit(
      roomType: CleaningRoomType.bedroom,
      index: 2,
      size: CleaningRoomSize.medium,
    ),
  ], DateTime.now().add(const Duration(days: 3)));
  draft = draft.replaceSchedule(
    draft.schedules.first.copyWith(workers: 2, workMinutes: 240),
  );
  return draft.replaceSchedule(draft.schedules.last.copyWith(workMinutes: 120));
}

void main() {
  late BookingTransport transport;
  late ClMainBloc bloc;
  late Map<String, dynamic> saved;
  setUp(() async {
    await getIt.reset();
    final network = DioNetwork(baseUrl: 'http://booking.test');
    DioNetwork.dio.interceptors.clear();
    transport = BookingTransport();
    DioNetwork.dio.httpClientAdapter = transport;
    final source = ClMainRemoteDataSource(dioNetwork: network);
    getIt.registerSingleton<ClMainRemoteDataSource>(source);
    final repo = ClMainRepoImpl(clMainRemoteDataSource: source);
    bloc = ClMainBloc(
      estimateCleaningPriceUseCase: EstimateCleaningPriceUseCase(
        clMainRepo: repo,
      ),
      getCleaningServicesUseCase: GetCleaningServicesUseCase(clMainRepo: repo),
      getPreviousCleaningWorkersUseCase: GetPreviousCleaningWorkersUseCase(
        clMainRepo: repo,
      ),
      createCleaningOrderUseCase: CreateCleaningOrderUseCase(clMainRepo: repo),
    );
    saved = {
      'bookingV2': sharedPeriod(),
      'v2Gender': CleaningGenderPreference.male,
      'v2Terms': true,
    };
  });
  tearDown(() async {
    await bloc.close();
    await getIt.reset();
  });

  Future<void> showStep(
    WidgetTester tester,
    int step, {
    bool fresh = false,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    if (!fresh) {
      saved['v2Step'] = step;
      saved['v2FlowVersion'] = 5;
    }
    if (step == 3) {
      final booking = saved['bookingV2'] as CleaningBookingDraft;
      saved['bookingV2'] = booking.replacePeriod(
        booking.periods.single.copyWith(
          materials: PeriodMaterialDecision(
            choice: CleaningMaterialChoice.customerAll,
          ),
          servicesReviewed: true,
        ),
      );
    }
    final draft = saved['bookingV2'] as CleaningBookingDraft;
    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: (settings) {
          if (settings.name == '/cleaning-order-details') {
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const Scaffold(body: Text('booking created')),
            );
          }
          return null;
        },
        home: CleaningBookingV2Screen(
          args: ClMainScheduleArgs(
            propertyType: 'apartment',
            bedrooms: 2,
            rooms: 0,
            bathrooms: 0,
            livingRoomSize: 'small',
            roomSizeBreakdown: const CleaningRoomSizeBreakdown(
              bedroom: CleaningRoomSizeBucket(medium: 2),
            ),
            roomUnits: draft.rooms,
            addressLatitude: 33.5,
            addressLongitude: 36.3,
            estimate: null,
            cleaningType: CleaningType.regularCleaning,
            bloc: bloc,
            defaultAddress: const AddressListItem(
              id: '10',
              label: 'المنزل',
              line1: 'دمشق',
              type: AddressType.home,
              latitude: 33.5,
              longitude: 36.3,
            ),
            draft: saved,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('fresh flow enters material needs before scheduling', (
    tester,
  ) async {
    await showStep(tester, 0, fresh: true);
    expect(find.text('4 / 7'), findsOneWidget);
    expect(find.byKey(const Key('booking_material_needs')), findsOneWidget);
    expect(find.byKey(const Key('booking_date')), findsNothing);
    expect(find.text('المواد جاهزة عندك؟'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'materials apply once to booking and never expose period or visit controls',
    (tester) async {
      await showStep(tester, 0);
      expect(find.text('المواد جاهزة عندك؟'), findsOneWidget);
      expect(find.text('من سيوفر مواد التنظيف؟'), findsOneWidget);
      expect(find.text('كل المواد متوفرة عندي'), findsOneWidget);
      expect(find.text('تنقصني بعض المواد'), findsOneWidget);
      expect(find.text('أحتاج توفير مواد التنظيف'), findsOneWidget);
      expect(find.textContaining('الفترة'), findsNothing);
      expect(find.textContaining('الزيارة'), findsNothing);
      expect(find.byKey(const Key('booking_period_details')), findsNothing);
      await tester.tap(find.byKey(const Key('material_choice_customer_all')));
      await tester.pump();
      expect(
        (saved['bookingV2'] as CleaningBookingDraft).periods.every(
          (period) =>
              period.materials.choice == CleaningMaterialChoice.customerAll,
        ),
        isTrue,
      );
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('appointment combines date address team and recurrence', (
    tester,
  ) async {
    await showStep(tester, 2);
    expect(find.byKey(const Key('booking_date')), findsOneWidget);
    expect(find.byKey(const Key('booking_time')), findsOneWidget);
    expect(find.byKey(const Key('booking_finish')), findsOneWidget);
    expect(find.byKey(const Key('booking_team_count')), findsOneWidget);
    expect(find.byKey(const Key('booking_recurring_toggle')), findsOneWidget);
    expect(find.text('عنوان الخدمة'), findsWidgets);
    expect(find.textContaining('الفترة'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('team size independent of room count and supervisor text', (
    tester,
  ) async {
    await showStep(tester, 2);
    await tester.ensureVisible(find.byKey(const Key('booking_team_plus')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('booking_team_plus')));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('booking_team_plus')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('booking_team_plus')));
    await tester.pump();
    expect(find.text('3'), findsWidgets);
    expect(
      find.byKey(const Key('booking_team_supervisor_notice')),
      findsOneWidget,
    );
    expect((saved['bookingV2'] as CleaningBookingDraft).peakWorkers, 3);
    await tester.pumpAndSettle();
    expect(saved['v2TeamWorkers'], 3);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'early material preview provides live team duration without quotation',
    (tester) async {
      final original = saved['bookingV2'] as CleaningBookingDraft;
      saved['bookingV2'] = CleaningBookingDraft.fromRooms(
        original.rooms,
        DateTime.now().add(const Duration(days: 3)),
      );
      await showStep(tester, 2);
      final hydrated = saved['bookingV2'] as CleaningBookingDraft;
      expect(
        hydrated.schedules.every((s) => s.workMinutes != null),
        isTrue,
        reason: hydrated.schedules
            .map((s) => '${s.roomKey}:${s.workMinutes}')
            .join(','),
      );
      final durationLabel = find.byKey(const Key('booking_total_duration'));
      expect(durationLabel, findsOneWidget);
      final originalMinutes = tester.widget<Text>(durationLabel).data;
      await tester.ensureVisible(find.byKey(const Key('booking_team_plus')));
      await tester.tap(find.byKey(const Key('booking_team_plus')));
      await tester.pumpAndSettle();
      final shorterMinutes = tester.widget<Text>(durationLabel).data;
      expect(originalMinutes, isNot(shorterMinutes));
      expect(transport.estimates, isEmpty);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('one worker covers several rooms sequentially', (tester) async {
    await showStep(tester, 2);
    final draft = saved['bookingV2'] as CleaningBookingDraft;
    expect(draft.schedules, hasLength(2));
    expect(draft.peakWorkers, 1);
    expect(
      draft.schedules.last.start.isAfter(draft.schedules.first.start),
      isTrue,
    );
    expect(find.byKey(const Key('booking_total_duration')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'weekly recurring creates two actual visits in quotation payload',
    (tester) async {
      await showStep(tester, 2);
      await tester.ensureVisible(
        find.byKey(const Key('booking_recurring_toggle')),
      );
      await tester.tap(find.byKey(const Key('booking_recurring_toggle')));
      await tester.pumpAndSettle();
      final savedDraft = saved['bookingV2'] as CleaningBookingDraft;
      expect(savedDraft.schedules.map((s) => s.visitKey).toSet().length, 2);
      expect(
        (saved['bookingV2'] as CleaningBookingDraft).toJson()['visits'],
        hasLength(2),
      );
      expect(find.byKey(const Key('booking_repeat_weekly')), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'server errors identify affected room from combined appointment',
    (tester) async {
      await showStep(tester, 2);
      transport.invalidSchedule = true;
      await tester.ensureVisible(find.byKey(const Key('booking_team_plus')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('booking_team_plus')));
      await tester.pumpAndSettle();
      // No pricing request is made for a simple worker count change.
      await tester.tap(find.text('متابعة'));
      await tester.pumpAndSettle();
      expect(find.text('عدد العمال غير متاح لهذه الغرفة'), findsWidgets);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'timeout freezes exact attempt and retry preserves signature and idempotency identity',
    (tester) async {
      await showStep(tester, 3);
      transport.failCreate = true;
      await tester.tap(find.text('تأكيد وإنشاء الطلب'));
      await tester.pumpAndSettle();
      expect(find.text('التحقق وإعادة المحاولة'), findsOneWidget);
      expect(saved['v2PendingSubmission'], isNotNull);
      expect(
        find
            .byType(AbsorbPointer)
            .evaluate()
            .any((element) => (element.widget as AbsorbPointer).absorbing),
        isTrue,
      );
      await tester.tap(find.text('التحقق وإعادة المحاولة'));
      await tester.pumpAndSettle();
      expect(transport.submissions, hasLength(2));
      expect(transport.submissions.last, transport.submissions.first);
      final propertyDetails =
          transport.submissions.first['propertyDetails'] as Map;
      expect(propertyDetails['location_name'], 'المنزل');
      expect(propertyDetails.containsKey('locationName'), isFalse);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('materials preview loads when price estimation fails', (
    tester,
  ) async {
    transport.invalidSchedule = true;
    await showStep(tester, 0);
    expect(find.text('منظف الأرضيات'), findsOneWidget);
    expect(find.text('من سيوفر مواد التنظيف؟'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('materials preview is visible before provider choice', (
    tester,
  ) async {
    await showStep(tester, 0);
    expect(find.byKey(const Key('booking_material_needs')), findsOneWidget);
    expect(find.text('منظف الأرضيات'), findsOneWidget);
    expect(find.text('من سيوفر مواد التنظيف؟'), findsOneWidget);
    final preview = tester.getTopLeft(
      find.byKey(const Key('booking_material_needs')),
    );
    final supplier = tester.getTopLeft(find.text('من سيوفر مواد التنظيف؟'));
    expect(preview.dy, lessThan(supplier.dy));
    await tester.ensureVisible(
      find.byKey(const Key('material_choice_customer_partial')),
    );
    await tester.tap(find.byKey(const Key('material_choice_customer_partial')));
    await tester.pump();
    final materialCheckbox = find.byType(CheckboxListTile).first;
    await tester.ensureVisible(materialCheckbox);
    await tester.tap(materialCheckbox);
    await tester.pump();
    // Selecting the material marks it as missing and requests platform supply.
    expect((saved['v2MissingMaterialIds'] as List), contains(4));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'weekly visits keep one selected missing material instead of platform all',
    (tester) async {
      await showStep(tester, 0);
      final radio = find.byKey(const Key('material_choice_customer_partial'));
      await tester.ensureVisible(radio);
      await tester.tap(radio);
      await tester.pumpAndSettle();
      final missingCheckbox = find.byType(CheckboxListTile).first;
      await tester.ensureVisible(missingCheckbox);
      await tester.tap(missingCheckbox);
      await tester.pumpAndSettle();
      expect(saved['v2MaterialChoice'], CleaningMaterialChoice.customerPartial);
      expect(saved['v2MissingMaterialIds'], <int>[4]);
      await tester.pumpWidget(const SizedBox());
      await showStep(tester, 2);
      await tester.ensureVisible(
        find.byKey(const Key('booking_recurring_toggle')),
      );
      await tester.tap(find.byKey(const Key('booking_recurring_toggle')));
      await tester.pumpAndSettle();
      final visits =
          (saved['bookingV2'] as CleaningBookingDraft).toJson()['visits']
              as List;
      expect(visits, hasLength(2));
      for (final visit in visits) {
        for (final period in (visit as Map)['timePeriods'] as List) {
          final materials = (period as Map)['materials'] as Map;
          expect(materials['choice'], 'customer_partial');
          expect(materials['materialTypeIds'], <int>[4]);
        }
      }
      expect(saved['v2MaterialChoice'], CleaningMaterialChoice.customerPartial);
      expect(saved['v2MissingMaterialIds'], <int>[4]);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'selected partial materials survive actual next-step navigation, quote and submit',
    (tester) async {
      await showStep(tester, 0);
      final radio = find.byKey(const Key('material_choice_customer_partial'));
      await tester.ensureVisible(radio);
      await tester.tap(radio);
      await tester.pumpAndSettle();
      final missingCheckbox = find.byType(CheckboxListTile).first;
      await tester.ensureVisible(missingCheckbox);
      await tester.tap(missingCheckbox);
      await tester.pumpAndSettle();
      expect(saved['v2MaterialChoice'], CleaningMaterialChoice.customerPartial);
      expect(saved['v2MissingMaterialIds'], <int>[4]);

      await tester.tap(find.text('متابعة'));
      await tester.pumpAndSettle();
      expect(saved['v2Step'], 1);
      expect(saved['v2MaterialChoice'], CleaningMaterialChoice.customerPartial);

      await tester.tap(find.text('متابعة'));
      await tester.pumpAndSettle();
      expect(saved['v2Step'], 2);
      expect(saved['v2MaterialChoice'], CleaningMaterialChoice.customerPartial);
      await tester.ensureVisible(
        find.byKey(const Key('booking_recurring_toggle')),
      );
      await tester.tap(find.byKey(const Key('booking_recurring_toggle')));
      await tester.pumpAndSettle();
      for (final visit
          in (saved['bookingV2'] as CleaningBookingDraft).toJson()['visits']
              as List) {
        for (final period in (visit as Map)['timePeriods'] as List) {
          final materials = (period as Map)['materials'] as Map;
          expect(materials['choice'], 'customer_partial');
          expect(materials['materialTypeIds'], <int>[4]);
        }
      }
      await tester.tap(find.text('متابعة'));
      await tester.pumpAndSettle();
      expect(saved['v2Step'], 3);
      expect(find.text('تنقصني بعض المواد'), findsWidgets);
      expect(
        find.text('ستوفر المنصة المواد الناقصة المختارة فقط (1):'),
        findsOneWidget,
      );
      expect(find.text('بقية مواد التنظيف سيوفرها العميل.'), findsOneWidget);
      expect(saved['v2MaterialChoice'], CleaningMaterialChoice.customerPartial);
      await tester.tap(find.text('تأكيد وإنشاء الطلب'));
      await tester.pumpAndSettle();
      expect(transport.submissions, hasLength(1));
      final submission = transport.submissions.single;
      expect(submission['visits'], hasLength(2));
      for (final visit in submission['visits'] as List) {
        for (final period in (visit as Map)['timePeriods'] as List) {
          final materials = (period as Map)['materials'] as Map;
          expect(materials['choice'], 'customer_partial');
          expect(materials['materialTypeIds'], <int>[4]);
        }
      }
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('specialist services are optional without a blocking checkbox', (
    tester,
  ) async {
    await showStep(tester, 1);
    expect(find.text('لا أحتاج إلى خدمات إضافية'), findsNothing);
    expect(find.textContaining('اختيارية'), findsWidgets);
    await tester.tap(find.text('متابعة'));
    await tester.pumpAndSettle();
    expect(saved['v2Step'], 2);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('recurring appointments are vertical and readable', (
    tester,
  ) async {
    await showStep(tester, 2);
    await tester.ensureVisible(
      find.byKey(const Key('booking_recurring_toggle')),
    );
    await tester.tap(find.byKey(const Key('booking_recurring_toggle')));
    await tester.pumpAndSettle();
    final first = find.byKey(const Key('booking_recurrence_date_0'));
    final second = find.byKey(const Key('booking_recurrence_date_1'));
    expect(first, findsOneWidget);
    expect(second, findsOneWidget);
    expect(
      tester.getTopLeft(second).dy,
      greaterThan(tester.getTopLeft(first).dy),
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('exiting booking requires confirmation', (tester) async {
    await showStep(tester, 1);
    await tester.tap(find.byTooltip('الخروج من الطلب'));
    await tester.pumpAndSettle();
    expect(find.text('الخروج من طلب التنظيف؟'), findsOneWidget);
    await tester.tap(find.text('متابعة الطلب'));
    await tester.pumpAndSettle();
    expect(find.text('تفاصيل صغيرة، فرق كبير'), findsOneWidget);
    expect(saved['bookingV2'], isNotNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('specialist editor offers a close control without an error', (
    tester,
  ) async {
    await showStep(tester, 1);
    await tester.tap(find.byKey(const Key('special_service_8')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('special_service_close')), findsOneWidget);
    await tester.tap(find.byKey(const Key('special_service_close')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('special_service_close')), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'special service clearly marks selection and bills quantity only once',
    (tester) async {
      await showStep(tester, 1);
      final action = find.byKey(const Key('special_service_action_8'));
      expect(
        find.descendant(of: action, matching: find.text('+')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('special_service_8')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('special_service_save')));
      await tester.pumpAndSettle();
      final selected =
          (saved['v2BookingServices'] as List<PeriodSpecialistService>).single;
      expect(selected.targetRoomKeys, hasLength(1));
      final card = tester.widget<Container>(
        find.byKey(const Key('special_service_card_8')),
      );
      final border = (card.decoration! as BoxDecoration).border! as Border;
      expect(border.top.width, 2);
      expect(
        find.descendant(of: action, matching: find.text('تعديل')),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('materials collapse even when customer has partial materials', (
    tester,
  ) async {
    transport.materialPreviewCount = 5;
    await showStep(tester, 0);
    expect(find.byKey(const Key('booking_material_8')), findsNothing);
    final toggle = find.byKey(const Key('booking_expand_materials'));
    await tester.ensureVisible(toggle);
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('booking_material_8')), findsOneWidget);
    await tester.ensureVisible(
      find.byKey(const Key('material_choice_customer_partial')),
    );
    await tester.tap(find.byKey(const Key('material_choice_customer_partial')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(toggle);
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('booking_material_8')), findsNothing);
    expect(find.textContaining('عرض جميع المواد المطلوبة'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'review includes room modes, partial materials and targeted specialist services',
    (tester) async {
      saved['v2MaterialChoice'] = CleaningMaterialChoice.customerPartial;
      saved['v2MissingMaterialIds'] = <int>[4];
      saved['v2BookingServices'] = <PeriodSpecialistService>[
        PeriodSpecialistService(
          serviceKey: 'service.review',
          serviceId: 8,
          targetRoomKeys: const ['bedroom.1'],
          quantity: 2,
          dirtiness: 'heavy',
        ),
      ];
      await showStep(tester, 3);
      expect(find.text('الغرف ونوع التنظيف'), findsOneWidget);
      expect(find.text('العنوان والموعد'), findsOneWidget);
      expect(find.text('المواعيد والتكرار'), findsOneWidget);
      expect(find.text('الخدمات المتخصصة'), findsOneWidget);
      expect(find.textContaining('تنظيف الكنب'), findsWidgets);
      expect(find.textContaining('اتساخ شديد'), findsWidgets);
      expect(find.textContaining('منظف الأرضيات'), findsWidgets);
      expect(find.byKey(const Key('booking_review_notes')), findsOneWidget);
      expect(find.byKey(const Key('booking_total')), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('review shows signed server total instead of pending text', (
    tester,
  ) async {
    await showStep(tester, 3);
    expect(find.textContaining('350'), findsWidgets);
    expect(find.text('بانتظار تحديث الإجمالي'), findsNothing);
    expect(transport.estimates, isNotEmpty);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('monthly pattern skips missing day without moving to month end', (
    tester,
  ) async {
    var draft = sharedPeriod();
    for (final schedule in draft.schedules.toList()) {
      draft = draft.replaceSchedule(
        schedule.copyWith(start: DateTime(2027, 1, 31, 9)),
      );
    }
    saved['bookingV2'] = draft;
    await showStep(tester, 2);
    await tester.ensureVisible(
      find.byKey(const Key('booking_recurring_toggle')),
    );
    await tester.tap(find.byKey(const Key('booking_recurring_toggle')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('booking_repeat_monthly')));
    await tester.tap(find.byKey(const Key('booking_repeat_monthly')));
    await tester.pumpAndSettle();
    expect(saved['v2RecurrencePattern'], CleaningRecurringPattern.monthly);
    final dates = (saved['bookingV2'] as CleaningBookingDraft).schedules
        .where((item) => item.roomKey == 'bedroom.1')
        .map((item) => item.start.toIso8601String().substring(0, 10))
        .toList();
    expect(dates, ['2027-01-31', '2027-03-31']);
    expect(find.byKey(const Key('booking_repeat_monthly')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'specialized service editor updates existing item, not duplicate',
    (tester) async {
      await showStep(tester, 1);
      await tester.tap(find.byKey(const Key('special_service_8')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('special_service_save')));
      await tester.pumpAndSettle();
      var selections =
          saved['v2BookingServices'] as List<PeriodSpecialistService>;
      expect(selections, hasLength(1));
      final key = selections.single.serviceKey;
      await tester.ensureVisible(
        find.byKey(const Key('special_service_action_8')),
      );
      await tester.tap(find.byKey(const Key('special_service_action_8')));
      await tester.pumpAndSettle();
      expect(find.text('حفظ التعديلات'), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('special_service_quantity')),
        '2',
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('special_service_save')));
      await tester.pumpAndSettle();
      selections = saved['v2BookingServices'] as List<PeriodSpecialistService>;
      expect(selections, hasLength(1));
      expect(selections.single.serviceKey, key);
      expect(selections.single.quantity, 2);
      expect(selections.single.targetRoomKeys, contains('bedroom.1'));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'outside tap closes specialized editor without an error or selection',
    (tester) async {
      await showStep(tester, 1);
      await tester.tap(find.byKey(const Key('special_service_8')));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('special_service_save')), findsNothing);
      expect(saved['v2BookingServices'] as List, isEmpty);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
